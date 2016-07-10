//
//  Ruta.swift
//  Rutas
//
//  Created by Renán Díaz Reyes on 7/2/16.
//  Copyright © 2016 Renán Díaz Reyes. All rights reserved.
//

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
}