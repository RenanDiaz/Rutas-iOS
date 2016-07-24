//
//  RouteInfoController.swift
//  Rutas
//
//  Created by Renán Díaz Reyes on 7/8/16.
//  Copyright © 2016 Renán Díaz Reyes. All rights reserved.
//

import UIKit

class RouteInfoController: UIViewController {
  
  let defaultSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
  var dataTask: NSURLSessionDataTask?
  
  @IBOutlet weak var origenLabel: UILabel!
  @IBOutlet weak var destinoLabel: UILabel!
  @IBOutlet weak var tableView: UITableView!
  
  var ruta = Ruta()
  var asignacionesPorFechas = [AsignacionesPorFecha]()
  
  lazy var tapRecognizer: UITapGestureRecognizer = {
    var recognizer = UITapGestureRecognizer(target:self, action: #selector(RouteInfoController.dismissKeyboard))
    return recognizer
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = ruta.descripcion
  }
  
  override func viewWillAppear(animated: Bool) {
    origenLabel.text = ruta.origen!
    destinoLabel.text = ruta.destino!
    tableView.tableFooterView = UIView()
    self.cargarDatos()
  }
  
  func cargarDatos() {
    if dataTask != nil {
      dataTask?.cancel()
    }
    
    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    
    let url = NSURL(string: "http://190.141.120.200:8080/Rutas/rest/asignaciones?ruta=\(ruta.id!)")
    
    dataTask = defaultSession.dataTaskWithURL(url!) {
      data, response, error in
      
      dispatch_async(dispatch_get_main_queue()) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
      }
      
      if let error = error {
        print(error.localizedDescription)
      } else if let httpResponse = response as? NSHTTPURLResponse {
        if httpResponse.statusCode == 200 {
          self.actualizarDatos(data)
        }
      }
    }
    
    dataTask?.resume()
  }
  
  func actualizarDatos(data: NSData?) {
    asignacionesPorFechas.removeAll()
    do {
      if let data = data, response = try NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions(rawValue:0)) as? [String: AnyObject] {
        // Get the results array
        if let array: AnyObject = response["rutasAsignadas"] {
          for diccionarioDeAsignacion in array as! [AnyObject] {
            if let diccionarioDeAsignacion = diccionarioDeAsignacion as? [String: AnyObject], id = diccionarioDeAsignacion["id"] as? Int {
              
              var vehiculo = Vehiculo()
              if let objetoVehiculo: AnyObject = diccionarioDeAsignacion["vehiculo"] {
                if let placa = objetoVehiculo["placa"] as? String {
                  var marca = Marca()
                  if let objetoMarca: AnyObject = objetoVehiculo["marca"] {
                    if let id = objetoMarca["id"] as? Int {
                      let nombre = objetoMarca["nombre"] as? String
                      marca = Marca(id: id, nombre: nombre)
                    }
                  }
                  let modelo = objetoVehiculo["modelo"] as? String
                  let anno = objetoVehiculo["anno"] as? Int
                  let tipo = objetoVehiculo["tipo"] as? String
                  let nombre = objetoVehiculo["nombre"] as? String
                  let nombreCorto = objetoVehiculo["nombreCorto"] as? String
                  vehiculo = Vehiculo(placa: placa, marca: marca, modelo: modelo, anno: anno, tipo: tipo, nombre: nombre, nombreCorto: nombreCorto)
                }
              }
              
              var rutaDeLaAsignacion = Ruta()
              if let objetoRuta: AnyObject = diccionarioDeAsignacion["ruta"] {
                if let idRuta = objetoRuta["id"] as? Int {
                  let origen = objetoRuta["origen"] as? String
                  let destino = objetoRuta["destino"] as? String
                  let descripcion = objetoRuta["descripcion"] as? String
                  rutaDeLaAsignacion = Ruta(id: idRuta, origen: origen, destino: destino, descripcion: descripcion)
                }
              }
              
              let fechahoraDePartida = diccionarioDeAsignacion["fechahoraDePartida"] as? Double
              let fechahoraDeLlegada = diccionarioDeAsignacion["fechahoraDeLlegada"] as? Double
              let descripcion = diccionarioDeAsignacion["descripcion"] as? String
              let fechaDePartida = diccionarioDeAsignacion["fechaDePartida"] as? String
              let horaDePartida = diccionarioDeAsignacion["horaDePartida"] as? String
              let fechaDeLlegada = diccionarioDeAsignacion["fechaDeLlegada"] as? String
              let horaDeLlegada = diccionarioDeAsignacion["horaDeLlegada"] as? String
              let rangoDeHoras = diccionarioDeAsignacion["rangoDeHoras"] as? String
              let asignacion = Asignacion(id: id, vehiculo: vehiculo, ruta: rutaDeLaAsignacion, fechahoraDePartida: fechahoraDePartida, fechahoraDeLlegada: fechahoraDeLlegada, descripcion: descripcion, fechaDePartida: fechaDePartida, horaDePartida: horaDePartida, fechaDeLlegada: fechaDeLlegada, horaDeLlegada: horaDeLlegada, rangoDeHoras: rangoDeHoras)
              
              if !asignacionesPorFechas.contains({ asignacionesPorFecha in asignacionesPorFecha.fecha == fechaDePartida!}) {
                self.asignacionesPorFechas.append(AsignacionesPorFecha(fecha: fechaDePartida!))
              }
              
              let indice = self.asignacionesPorFechas.indexOf({$0.fecha == fechaDePartida!})
              self.asignacionesPorFechas[indice!].add(asignacion)
            } else {
              print("No es un diccionario")
            }
          }
        } else {
          print("Llave de los resultados no encontrados en el diccionario")
        }
      } else {
        print("Error en JSON")
      }
    } catch let error as NSError {
      print("Error parseando resultados: \(error.localizedDescription)")
    }
    
    dispatch_async(dispatch_get_main_queue()) {
      self.asignacionesPorFechas.sortInPlace({ $0.fecha < $1.fecha })
      self.tableView.reloadData()
    }
  }
  
  // MARK: Keyboard dismissal
  
  func dismissKeyboard() {
    
  }
  
  // MARK: Segue
  
  let mapSegueIdentifier = "ShowMapSegue"
  
  // MARK: - Navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == mapSegueIdentifier,
      let destination = segue.destinationViewController as? MapViewController,
      routeIndex = tableView.indexPathForSelectedRow?.row,
      routeSection = tableView.indexPathForSelectedRow?.section
    {
      destination.asignacion = asignacionesPorFechas[routeSection].asignaciones[routeIndex]
    }
  }
}
// MARK: UITableViewDataSource

extension RouteInfoController: UITableViewDataSource {
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return asignacionesPorFechas[section].asignaciones.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("AsignationCell", forIndexPath: indexPath) as!AsignationCell
    
    let asignacion = asignacionesPorFechas[indexPath.section].asignaciones[indexPath.row]
    
    cell.titleLabel.text = asignacion.rangoDeHorasFormateado()
    cell.subtitleLabel.text = asignacion.vehiculo?.nombreCorto
    
    return cell
  }
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    let numOfSections = asignacionesPorFechas.count
    if (numOfSections > 0)
    {
      tableView.backgroundView = nil
    }
    else
    {
      let noDataLabel: UILabel = UILabel(frame: CGRectMake(0, 0, self.tableView.bounds.size.width, self.tableView.bounds.size.height))
      noDataLabel.text = "No hay horarios asignados"
      noDataLabel.textColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.5)
      noDataLabel.textAlignment = NSTextAlignment.Center
      tableView.backgroundView = noDataLabel
    }
    
    return numOfSections
  }
  
  func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return asignacionesPorFechas[section].fechaFormateada()
  }
}

// MARK: UITableViewDelegate

extension RouteInfoController: UITableViewDelegate {
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 62.0
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
  }
}
