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
  var asignacion: Asignacion?
  var subtitle: String?
  var coordinate: CLLocationCoordinate2D
  
  init(id: Int?, fechahora: Double?, asignacion: Asignacion?, coordinate: CLLocationCoordinate2D) {
    self.id = id
    self.fechahora = NSDate(timeIntervalSince1970: fechahora!)
    self.asignacion = asignacion
    self.coordinate = coordinate
    self.title = asignacion!.vehiculo!.nombreCorto!
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