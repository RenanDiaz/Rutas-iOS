//
//  UbicacionViewController.swift
//  Rutas
//
//  Created by Renán Díaz Reyes on 7/2/16.
//  Copyright © 2016 Renán Díaz Reyes. All rights reserved.
//

import UIKit
import MapKit

class UbicacionViewController: UIViewController {
  
  let defaultSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
  var dataTask: NSURLSessionDataTask?

  @IBOutlet weak var picker: UIPickerView!
  @IBOutlet weak var boton: UIButton!
  @IBOutlet weak var mapView: MKMapView!
  
  var asignaciones = [Asignacion]()
  let locationManager = CLLocationManager()
  let METERS_PER_MILE: CDouble = 1609.344
  var debeEnviar = false
  var points = [CLLocationCoordinate2D]()
  var polyline = MKPolyline()
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    locationManager.requestWhenInUseAuthorization()
    mapView.delegate = self
    picker.dataSource = self
    picker.delegate = self
    cargarDatos()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    mapView.showsUserLocation = true
    getCurrentLocation()
  }

  @IBAction func tappedButton(sender: AnyObject) {
    debeEnviar = !debeEnviar
    if debeEnviar {
      boton.setTitle("Terminar", forState: UIControlState.Normal)
    } else {
      boton.setTitle("Empezar", forState: UIControlState.Normal)
    }
  }
  
  func cargarDatos() {
    if dataTask != nil {
      dataTask?.cancel()
    }
    
    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    
    let url = NSURL(string: "http://190.141.120.200:8080/Rutas/rest/asignaciones/hoy")
    
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
    asignaciones.removeAll()
    do {
      if let data = data, response = try NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions(rawValue:0)) as? [String: AnyObject] {
        // Get the results array
        if let array: AnyObject = response["asignaciones"] {
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
              
              asignaciones.append(asignacion)
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
      self.picker.reloadAllComponents()
    }
  }

  func enviarUbicacion(latitud: CLLocationDegrees, longitud: CLLocationDegrees) {
    if dataTask != nil {
      dataTask?.cancel()
    }
    
    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    let asignacion = asignaciones[picker.selectedRowInComponent(0)]
    let fecha = String(format: "%.0f", NSDate().timeIntervalSince1970 * 1000)
    
    let urlString = "http://190.141.120.200:8080/Rutas/ubicacion/agregar?fecha=\(fecha)&asignacion=\(asignacion.id!)&latitud=\(latitud)&longitud=\(longitud)"
//    print(urlString)
    
    let url = NSURL(string: urlString)
    let request = NSMutableURLRequest(URL: url!)
    request.HTTPMethod = "POST"
    
    dataTask = defaultSession.dataTaskWithRequest(request) {
      data, response, error in
      
      dispatch_async(dispatch_get_main_queue()) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
      }
      
      if let error = error {
        print(error.localizedDescription)
      } else if let httpResponse = response as? NSHTTPURLResponse {
        if httpResponse.statusCode == 200 {
          
        }
      }
    }
    
    dataTask?.resume()
  }
}

extension UbicacionViewController: UIPickerViewDataSource {
  
  func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
    return 1
  }
  
  func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return asignaciones.count
  }
}

extension UbicacionViewController: UIPickerViewDelegate {
  func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    
  }
  
  func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    let asignacion = asignaciones[row]
    return "\(asignacion.id!) - \(asignacion.descripcion!)"
  }
}

extension UbicacionViewController: CLLocationManagerDelegate {
  
  func getCurrentLocation() {
    locationManager.requestAlwaysAuthorization()
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.startUpdatingLocation()
  }
  
  func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
    print("Error al cargar ubicación: \(error)")
  }
  
  func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
    mapView.showsUserLocation = (status == .AuthorizedAlways)
  }
  
  func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
    var zoomLocation = CLLocationCoordinate2D()
    zoomLocation.latitude = newLocation.coordinate.latitude
    zoomLocation.longitude = newLocation.coordinate.longitude
    
    let viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 0.5 * METERS_PER_MILE, 0.5 * METERS_PER_MILE)
    mapView.setRegion(viewRegion, animated: true)
    if debeEnviar {
      enviarUbicacion(zoomLocation.latitude, longitud: zoomLocation.longitude)
      points.append(zoomLocation)
      trazarRecorrido()
    }
  }
  
  func trazarRecorrido() {
    if mapView.overlays.count > 0 {
      mapView.removeOverlay(polyline)
    }
    polyline = MKPolyline(coordinates: &points, count: points.count)
    mapView.addOverlay(polyline)
  }
}

extension UbicacionViewController: MKMapViewDelegate {
  
  func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
    if overlay is MKPolyline {
      let polylineRenderer = MKPolylineRenderer(overlay: overlay)
      polylineRenderer.strokeColor = UIColor.init(red: 0, green: 0, blue: 1, alpha: 0.5)
      polylineRenderer.lineWidth = 5
      return polylineRenderer
    }
    
    return MKPolylineRenderer()
  }
}
