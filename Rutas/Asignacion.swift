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
  var fechahoraDePartida: NSDate?
  var fechahoraDeLlegada: NSDate?
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
    self.fechahoraDePartida = NSDate(timeIntervalSince1970: fechahoraDePartida!)
    self.fechahoraDeLlegada = NSDate(timeIntervalSince1970: fechahoraDeLlegada!)
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
  func formatShortTimeToLocalizedTime(timeString: String) -> String {
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "HH:mm"
    let time = dateFormatter.dateFromString(timeString)
    
    dateFormatter.dateStyle = NSDateFormatterStyle.NoStyle
    dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
    dateFormatter.timeZone = NSTimeZone.localTimeZone()
    dateFormatter.locale = NSLocale.currentLocale()
    return dateFormatter.stringFromDate(time!)
  }
}