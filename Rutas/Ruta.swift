//
//  Ruta.swift
//  Rutas
//
//  Created by Renán Díaz Reyes on 7/2/16.
//  Copyright © 2016 Renán Díaz Reyes. All rights reserved.
//

class Ruta {
  var id: Int?
  var origen: String?
  var destino: String?
  var descripcion: String?
  
  init(id: Int?, origen: String?, destino: String?, descripcion: String?) {
    self.id = id
    self.origen = origen
    self.destino = destino
    self.descripcion = descripcion
  }
  
  init() {
    
  }
}