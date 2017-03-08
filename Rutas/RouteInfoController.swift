//
//  RouteInfoController.swift
//  Rutas
//
//  Created by Renán Díaz Reyes on 7/8/16.
//  Copyright © 2016 Renán Díaz Reyes. All rights reserved.
//

import UIKit

class RouteInfoController: UIViewController {
  
  let defaultSession = URLSession(configuration: URLSessionConfiguration.default)
  var dataTask: URLSessionDataTask?
  
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
  
  override func viewWillAppear(_ animated: Bool) {
    origenLabel.text = ruta.origen!
    destinoLabel.text = ruta.destino!
    tableView.tableFooterView = UIView()
    self.cargarDatos()
  }
  
  func cargarDatos() {
    if dataTask != nil {
      dataTask?.cancel()
    }
    
    UIApplication.shared.isNetworkActivityIndicatorVisible = true
    
    let url = URL(string: "http://190.141.120.200:8080/Rutas/rest/asignaciones/hoy?ruta=\(ruta.id!)")
    
    dataTask = defaultSession.dataTask(with: url!, completionHandler: {
      data, response, error in
      
      DispatchQueue.main.async {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
      }
      
      if let error = error {
        print(error.localizedDescription)
      } else if let httpResponse = response as? HTTPURLResponse {
        if httpResponse.statusCode == 200 {
          self.actualizarDatos(data)
        }
      }
    }) 
    
    dataTask?.resume()
  }
  
  func actualizarDatos(_ data: Data?) {
    asignacionesPorFechas.removeAll()
    do {
      if let data = data, let response = try JSONSerialization.jsonObject(with: data, options:JSONSerialization.ReadingOptions(rawValue:0)) as? [String: AnyObject] {
        // Get the results array
        if let array: AnyObject = response["asignaciones"] {
          for diccionarioDeAsignacion in array as! [AnyObject] {
            if let diccionarioDeAsignacion = diccionarioDeAsignacion as? [String: AnyObject], let id = diccionarioDeAsignacion["id"] as? Int {
              
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
              
              if !asignacionesPorFechas.contains(where: { asignacionesPorFecha in asignacionesPorFecha.fecha == fechaDePartida!}) {
                self.asignacionesPorFechas.append(AsignacionesPorFecha(fecha: fechaDePartida!))
              }
              
              let indice = self.asignacionesPorFechas.index(where: {$0.fecha == fechaDePartida!})
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
    
    DispatchQueue.main.async {
      self.asignacionesPorFechas.sort(by: { $0.fecha < $1.fecha })
      self.tableView.reloadData()
    }
  }
  
  // MARK: Keyboard dismissal
  
  func dismissKeyboard() {
    
  }
  
  // MARK: Segue
  
  let mapSegueIdentifier = "ShowMapSegue"
  
  // MARK: - Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == mapSegueIdentifier,
      let destination = segue.destination as? MapViewController,
      let routeIndex = tableView.indexPathForSelectedRow?.row,
      let routeSection = tableView.indexPathForSelectedRow?.section
    {
      destination.asignacion = asignacionesPorFechas[routeSection].asignaciones[routeIndex]
    }
  }
}
// MARK: UITableViewDataSource

extension RouteInfoController: UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return asignacionesPorFechas[section].asignaciones.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "AsignationCell", for: indexPath) as!AsignationCell
    
    let asignacion = asignacionesPorFechas[indexPath.section].asignaciones[indexPath.row]
    
    cell.titleLabel.text = asignacion.rangoDeHorasFormateado()
    cell.subtitleLabel.text = asignacion.vehiculo?.nombreCorto
    
    return cell
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    let numOfSections = asignacionesPorFechas.count
    if (numOfSections > 0)
    {
      tableView.backgroundView = nil
    }
    else
    {
      let noDataLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: self.tableView.bounds.size.height))
      noDataLabel.text = "No hay horarios asignados"
      noDataLabel.textColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.5)
      noDataLabel.textAlignment = NSTextAlignment.center
      tableView.backgroundView = noDataLabel
    }
    
    return numOfSections
  }
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return asignacionesPorFechas[section].fechaFormateada()
  }
}

// MARK: UITableViewDelegate

extension RouteInfoController: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 62.0
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
  }
}
