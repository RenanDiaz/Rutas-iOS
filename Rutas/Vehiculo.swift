//
//  Ruta.swift
//  Rutas
//
//  Created by Renán Díaz Reyes on 7/2/16.
//  Copyright © 2016 Renán Díaz Reyes. All rights reserved.
//

class Vehiculo {
  var placa: String?
  var marca: Marca?
  var modelo: String?
  var anno: Int?
  var tipo: String?
  var nombre: String?
  var nombreCorto: String?
  
  init(placa: String?, marca: Marca?, modelo: String?, anno: Int?, tipo: String?, nombre: String?, nombreCorto: String?) {
    self.placa = placa
    self.marca = marca
    self.modelo = modelo
    self.anno = anno
    self.tipo = tipo
    self.nombre = nombre
    self.nombreCorto = nombreCorto
  }
  
  init() {
    
  }
}