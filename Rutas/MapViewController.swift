//
//  MapViewController.swift
//  Rutas
//
//  Created by Renán Díaz Reyes on 7/11/16.
//  Copyright © 2016 Renán Díaz Reyes. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
  
  let defaultSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
  var dataTask: NSURLSessionDataTask?

  @IBOutlet weak var mapView: MKMapView!
  @IBOutlet weak var tiempoLabel: UILabel!
  @IBOutlet weak var distanciaLabel: UILabel!
  
  var ubicacionActual = CLLocation()
  let locationManager = CLLocationManager()
  
  var asignacion = Asignacion()
  var ultimaUbicacion = Ubicacion()
  var ubicaciones = [Ubicacion]()
  var shouldUpdate = true
  
  let METERS_PER_MILE: CDouble = 1609.344
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    locationManager.requestWhenInUseAuthorization()
    mapView.delegate = self
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = asignacion.vehiculo?.nombreCorto
    cargarDatos()
    getCurrentLocation()
  }
  
  @IBAction func setMapType(sender: UISegmentedControl) {
    switch sender.selectedSegmentIndex {
    case 0:
      mapView.mapType = MKMapType.Standard;
      break
    case 1:
      mapView.mapType = MKMapType.Satellite;
      break
    case 2:
      mapView.mapType = MKMapType.Hybrid;
      break
    default:
      break
    }
  }
  
  func cargarDatos() {
    if dataTask != nil {
      dataTask?.cancel()
    }
    
    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    
    let url = NSURL(string: "http://190.141.120.200:8080/Rutas/rest/ultimo-recorrido?asignacion=\(asignacion.id!)")
    
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
    ultimaUbicacion = Ubicacion()
    do {
      if let data = data, response = try NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions(rawValue:0)) as? [String: AnyObject] {
        if let objetoUbicacion: AnyObject = response["ultimaUbicacion"] {
          agregarUbicaciones(objetoUbicacion, ultima: true)
        } else {
          print("Llave de los resultados no encontrados en el diccionario")
        }
        if let array: AnyObject = response["ubicaciones"] {
          for diccionarioDeUbicacion in array as! [AnyObject] {
            agregarUbicaciones(diccionarioDeUbicacion, ultima: false)
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
      self.marcarUbicacionBus()
      self.trazarRecorrido()
    }
  }
  
  func agregarUbicaciones(objetoUbicacion: AnyObject, ultima: Bool) {
    if let id = objetoUbicacion["id"] as? Int {
      
      var asignacion = Asignacion()
      if let diccionarioDeAsignacion = objetoUbicacion["asignacion"] as? [String: AnyObject], id = diccionarioDeAsignacion["id"] as? Int {
        
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
        asignacion = Asignacion(id: id, vehiculo: vehiculo, ruta: rutaDeLaAsignacion, fechahoraDePartida: fechahoraDePartida, fechahoraDeLlegada: fechahoraDeLlegada, descripcion: descripcion, fechaDePartida: fechaDePartida, horaDePartida: horaDePartida, fechaDeLlegada: fechaDeLlegada, horaDeLlegada: horaDeLlegada, rangoDeHoras: rangoDeHoras)
      }
      
      let fechahora = objetoUbicacion["fechahora"] as? Double
      let latitud = (objetoUbicacion["latitud"] as? NSString)?.doubleValue
      let longitud = (objetoUbicacion["longitud"] as? NSString)?.doubleValue
      
      let latitude = CLLocationDegrees.init(latitud!)
      let longitude = CLLocationDegrees.init(longitud!)
      let coordinate = CLLocationCoordinate2DMake(latitude, longitude)
      
      let ubicacion = Ubicacion(id: id, fechahora: fechahora, asignacion: asignacion, coordinate: coordinate);
      if ultima {
        ultimaUbicacion = ubicacion
        setAddress(CLLocation(latitude: latitude, longitude: longitude))
      } else {
        ubicaciones.append(ubicacion)
      }
    } else {
      print("No es un diccionario")
    }
  }
  
  func trazarRecorrido() {
    var points = [CLLocationCoordinate2D]()
    for ubicacion in ubicaciones {
      points.append(ubicacion.coordinate)
    }
    
    let polyline = MKPolyline(coordinates: &points, count: points.count)
    mapView.addOverlay(polyline)
  }
}

extension MapViewController: CLLocationManagerDelegate {
  
  func getCurrentLocation() {
    locationManager.requestWhenInUseAuthorization()
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.startUpdatingLocation()
  }
  
  func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
    print("Error al cargar ubicación: \(error)")
  }
  
  func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
    mapView.showsUserLocation = (status == .AuthorizedWhenInUse)
  }
  
  func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
    
    if shouldUpdate {
      self.ubicacionActual = newLocation
      var zoomLocation = CLLocationCoordinate2D()
      zoomLocation.latitude = newLocation.coordinate.latitude
      zoomLocation.longitude = newLocation.coordinate.longitude
      
      let viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 0.5 * METERS_PER_MILE, 0.5 * METERS_PER_MILE)
      mapView.setRegion(viewRegion, animated: true)
    }
    //calcularDistancia()
  }
  
  func marcarUbicacionBus() {
    mapView.addAnnotation(ultimaUbicacion)
  }
  
  func setAddress(location: CLLocation) {
    // Reverse Geocoding
    CLGeocoder().reverseGeocodeLocation(location, completionHandler:
      {(placemarks, error) in
        if error != nil {
          print("reverse geocode error: \(error.debugDescription)");
        } else {
          let placemark = placemarks!.last! as CLPlacemark
          if placemark.locality != nil {
            if placemark.thoroughfare != nil {
              self.ultimaUbicacion.establecerDireccion("\(placemark.thoroughfare!), \(placemark.locality!)")
            } else {
              self.ultimaUbicacion.establecerDireccion("\(placemark.locality!)")
            }
          }
        }
      })
  }
  
  func calcularDistancia() {
    let source = MKMapItem( placemark: MKPlacemark(coordinate: ultimaUbicacion.coordinate, addressDictionary: nil))
    let destination = MKMapItem(placemark: MKPlacemark(coordinate: ubicacionActual.coordinate, addressDictionary: nil))
    
    let directionsRequest = MKDirectionsRequest()
    directionsRequest.source = source
    directionsRequest.destination = destination
    
    let directions = MKDirections(request: directionsRequest)
    
    directions.calculateDirectionsWithCompletionHandler { (response, error) -> Void in
      print(error)
      let distance = response!.routes.first?.distance // meters
      self.distanciaLabel.text = "\(distance! / 1000)km"
      let time = response!.routes.first?.expectedTravelTime // seconds
      self.tiempoLabel.text = "\(time! / 60) minutos"
    }
  }
}

extension MapViewController: MKMapViewDelegate {
  
  func mapView(mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
    shouldUpdate = !mapViewRegionDidChangeFromUserInteraction()
    if (!shouldUpdate) {
      locationManager.stopUpdatingLocation()
    }
  }
  
  private func mapViewRegionDidChangeFromUserInteraction() -> Bool {
    let view: UIView = self.mapView.subviews[0] as UIView
    //  Look through gesture recognizers to determine whether this region change is from user interaction
    if let gestureRecognizers = view.gestureRecognizers {
      for recognizer in gestureRecognizers {
        if( recognizer.state == UIGestureRecognizerState.Began || recognizer.state == UIGestureRecognizerState.Ended ) {
          return true
        }
      }
    }
    return false
  }
  
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
