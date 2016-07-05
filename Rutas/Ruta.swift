//
//  Ruta.swift
//  Rutas
//
//  Created by Renán Díaz Reyes on 7/2/16.
//  Copyright © 2016 Renán Díaz Reyes. All rights reserved.
//

class Ruta {
  var id: Int?
  var partida: String?
  var destino: String?
  
  init(id: Int?, partida: String?, destino: String?) {
    self.id = id
    self.partida = partida
    self.destino = destino
  }
}