//
//  MapViewController.swift
//  Rutas
//
//  Created by Renán Díaz Reyes on 7/11/16.
//  Copyright © 2016 Renán Díaz Reyes. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

  @IBOutlet weak var mapView: MKMapView!
  let geocoder = CLGeocoder()
  let locationManager = CLLocationManager()
  
  var asignacion = Asignacion()
  
  let METERS_PER_MILE: CDouble = 1609.344
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    locationManager.requestWhenInUseAuthorization()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = asignacion.vehiculo?.nombreCorto
    getCurrentLocation()
  }
  
  @IBAction func setMapType(sender: UISegmentedControl) {
    switch sender.selectedSegmentIndex {
    case 0:
      mapView.mapType = MKMapType.Standard;
      break
    case 1:
      mapView.mapType = MKMapType.Satellite;
      break
    case 2:
      mapView.mapType = MKMapType.Hybrid;
      break
    default:
      break
    }
  }
}

extension MapViewController: CLLocationManagerDelegate {
  
  func getCurrentLocation() {
    locationManager.requestWhenInUseAuthorization()
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.startUpdatingLocation()
  }
  
  func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
    print("Error al cargar ubicación: \(error)")
  }
  
  func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
    mapView.showsUserLocation = (status == .AuthorizedWhenInUse)
  }
  
  func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
    
    var zoomLocation = CLLocationCoordinate2D()
    zoomLocation.latitude = newLocation.coordinate.latitude
    zoomLocation.longitude = newLocation.coordinate.longitude
    
    let viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 0.5*METERS_PER_MILE, 0.5*METERS_PER_MILE)
    mapView.setRegion(viewRegion, animated: true)
  }
}
