//
//  Asignacion.swift
//  Asignacion
//
//  Created by Renán Díaz Reyes on 7/2/16.
//  Copyright © 2016 Renán Díaz Reyes. All rights reserved.
//

import Foundation

class Asignacion {
  var id: Int?
  var vehiculo: Vehiculo?
  var ruta: Ruta?
  var fechahoraDePartida: Date?
  var fechahoraDeLlegada: Date?
  var descripcion: String?
  var fechaDePartida: String?
  var horaDePartida: String?
  var fechaDeLlegada: String?
  var horaDeLlegada: String?
  var rangoDeHoras: String?
  
  init(id: Int?, vehiculo: Vehiculo?, ruta: Ruta?, fechahoraDePartida: Double?, fechahoraDeLlegada: Double?, descripcion: String?, fechaDePartida: String?, horaDePartida: String?, fechaDeLlegada: String?, horaDeLlegada: String?, rangoDeHoras: String?) {
    self.id = id
    self.vehiculo = vehiculo
    self.ruta = ruta
    self.fechahoraDePartida = Date(timeIntervalSince1970: fechahoraDePartida!)
    self.fechahoraDeLlegada = Date(timeIntervalSince1970: fechahoraDeLlegada!)
    self.descripcion = descripcion
    self.fechaDePartida = fechaDePartida
    self.horaDePartida = horaDePartida
    self.fechaDeLlegada = fechaDeLlegada
    self.horaDeLlegada = horaDeLlegada
    self.rangoDeHoras = rangoDeHoras
  }
  
  init(){
    
  }
  
  func rangoDeHorasFormateado() -> String {
    return "\(formatShortTimeToLocalizedTime(horaDePartida!)) - \(formatShortTimeToLocalizedTime(horaDeLlegada!))"
  }
  func formatShortTimeToLocalizedTime(_ timeString: String) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH:mm"
    let time = dateFormatter.date(from: timeString)
    
    dateFormatter.dateStyle = DateFormatter.Style.none
    dateFormatter.timeStyle = DateFormatter.Style.short
    dateFormatter.timeZone = TimeZone.autoupdatingCurrent
    dateFormatter.locale = Locale.current
    return dateFormatter.string(from: time!)
  }
}
