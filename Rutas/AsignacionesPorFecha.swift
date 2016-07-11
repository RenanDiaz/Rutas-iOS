//
//  Ruta.swift
//  Rutas
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
  
  func add(asignacion: Asignacion) {
    self.asignaciones.append(asignacion)
  }
  
  func fechaFormateada() -> String {
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    let date = dateFormatter.dateFromString(fecha)
    
    dateFormatter.dateStyle = NSDateFormatterStyle.FullStyle
    dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
    dateFormatter.timeZone = NSTimeZone.localTimeZone()
    dateFormatter.locale = NSLocale.currentLocale()
    return dateFormatter.stringFromDate(date!)
  }
}