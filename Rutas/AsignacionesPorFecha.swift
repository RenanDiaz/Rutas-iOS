//
//  AsignacionesPorFecha.swift
//  AsignacionesPorFecha
//
//  Created by Renán Díaz Reyes on 7/2/16.
//  Copyright © 2016 Renán Díaz Reyes. All rights reserved.
//

import Foundation

class AsignacionesPorFecha {
  var fecha: String
  var asignaciones: [Asignacion]
  
  init(fecha: String) {
    self.fecha = fecha
    self.asignaciones = [Asignacion]()
  }
  
  func add(_ asignacion: Asignacion) {
    self.asignaciones.append(asignacion)
  }
  
  func fechaFormateada() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    let date = dateFormatter.date(from: fecha)
    
    dateFormatter.dateStyle = DateFormatter.Style.full
    dateFormatter.timeStyle = DateFormatter.Style.none
    dateFormatter.timeZone = TimeZone.autoupdatingCurrent
    dateFormatter.locale = Locale.current
    return dateFormatter.string(from: date!)
  }
}
