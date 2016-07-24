//
//  Ubicacion.swift
//  Rutas
//
//  Created by Renán Díaz Reyes on 7/11/16.
//  Copyright © 2016 Renán Díaz Reyes. All rights reserved.
//

import MapKit

class Ubicacion: NSObject, MKAnnotation{
  var title: String?
  var id: Int?
  var fechahora: NSDate?
  var vehiculo: Vehiculo?
  var ruta: Ruta?
  var subtitle: String?
  var coordinate: CLLocationCoordinate2D
  
  init(id: Int?, fechahora: Double?, vehiculo: Vehiculo?, ruta: Ruta?, coordinate: CLLocationCoordinate2D) {
    self.id = id
    self.fechahora = NSDate(timeIntervalSince1970: fechahora!)
    self.vehiculo = vehiculo
    self.ruta = ruta
    self.coordinate = coordinate
    self.title = vehiculo!.nombreCorto!
    super.init()
  }
  
  override init() {
    let latitude = CLLocationDegrees.init(0)
    let longitude = CLLocationDegrees.init(0)
    self.coordinate = CLLocationCoordinate2DMake(latitude, longitude)
    super.init()
  }
  
  func establecerDireccion(direccion: String) {
    self.subtitle = direccion
  }
}