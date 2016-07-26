//
//  RutasViewController.swift
//  Rutas
//
//  Created by Renán Díaz Reyes on 7/2/16.
//  Copyright © 2016 Renán Díaz Reyes. All rights reserved.
//

import UIKit

class RutasViewController: UIViewController {
  
  let defaultSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
  var dataTask: NSURLSessionDataTask?
  
  @IBOutlet weak var tableView: UITableView!
  var searchBar: UISearchBar!
  
  var rutas = [Ruta]()
  var resultados = [Ruta]()
  var cargar = true
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    if cargar {
      cargar = false
      tableView.tableFooterView = UIView()
      searchBar = UISearchBar.init(frame: CGRectMake(0, 0, self.tableView.bounds.size.width, 44))
      searchBar.placeholder = "Buscar rutas"
      searchBar.delegate = self
      tableView.tableHeaderView = searchBar
      cargarDatos()
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.automaticallyAdjustsScrollViewInsets = false
  }
  
  func cargarDatos() {
    if searchBar.text!.isEmpty {
      if dataTask != nil {
        dataTask?.cancel()
      }
      
      UIApplication.sharedApplication().networkActivityIndicatorVisible = true
      
      let url = NSURL(string: "http://190.141.120.200:8080/Rutas/rest/rutas")
      
      dataTask = defaultSession.dataTaskWithURL(url!) {
        data, response, error in
        
        dispatch_async(dispatch_get_main_queue()) {
          UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        }
        
        if let error = error {
          print(error.localizedDescription)
        } else if let httpResponse = response as? NSHTTPURLResponse {
          if httpResponse.statusCode == 200 {
            self.actualizarDatos(data)
          }
        }
      }
      
      dataTask?.resume()
    }
  }
  
  func actualizarDatos(data: NSData?) {
    rutas.removeAll()
    do {
      if let data = data, response = try NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions(rawValue:0)) as? [String: AnyObject] {
        // Get the results array
        if let array: AnyObject = response["rutas"] {
          for diccionarioDeRuta in array as! [AnyObject] {
            if let diccionarioDeRuta = diccionarioDeRuta as? [String: AnyObject], id = diccionarioDeRuta["id"] as? Int {
              let origen = diccionarioDeRuta["origen"] as? String
              let destino = diccionarioDeRuta["destino"] as? String
              let descripcion = diccionarioDeRuta["descripcion"] as? String
              rutas.append(Ruta(id: id, origen: origen, destino: destino, descripcion: descripcion))
            } else {
              print("No es un diccionario")
            }
          }
        } else {
          print("Llave de los resultados no encontrados en el diccionario")
        }
      } else {
        print("Error en JSON")
      }
    } catch let error as NSError {
      print("Error parseando resultados: \(error.localizedDescription)")
    }
    
    resultados = rutas
    
    dispatch_async(dispatch_get_main_queue()) {
      self.tableView.reloadData()
      self.tableView.setContentOffset(CGPointMake(0, 44), animated: false)
    }
  }
  
  // MARK: Keyboard dismissal
  
  func dismissKeyboard() {
    searchBar.resignFirstResponder()
  }
  
  // MARK: Segue
  
  let routeSegueIdentifier = "ShowRouteInfoSegue"
  
  // MARK: - Navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if  segue.identifier == routeSegueIdentifier,
      let destination = segue.destinationViewController as? RouteInfoController,
      routeIndex = tableView.indexPathForSelectedRow?.row
    {
      destination.ruta = resultados[routeIndex]
    }
  }
}

// MARK: UISearchBarDelegate

extension RutasViewController: UISearchBarDelegate {
  
  func searchBarSearchButtonClicked(searchBar: UISearchBar) {
    
    dismissKeyboard()
  }
  
  func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
    filterContentForSearchText(searchText)
  }

  func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
    return .TopAttached
  }
  
  func filterContentForSearchText(searchText: String) {
    
    if self.rutas.count == 0 {
      self.resultados.removeAll()
      return
    }
    
    self.resultados = self.rutas.filter({( ruta: Ruta) -> Bool in
      var text = searchText
      if text.isEmpty {
        text = " "
      }
      return ruta.descripcion!.lowercaseString.rangeOfString(text.lowercaseString) != nil
    })
    
    dispatch_async(dispatch_get_main_queue()) {
      self.tableView.reloadData()
      self.tableView.setContentOffset(CGPointZero, animated: false)
    }
  }
}

// MARK: UITableViewDataSource

extension RutasViewController: UITableViewDataSource {
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return resultados.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("RouteCell", forIndexPath: indexPath) as!RouteCell
    
    let route = resultados[indexPath.row]
    
    cell.titleLabel.text = route.descripcion
    cell.subtitleLabel.text = String(route.id!)
    
    return cell
  }
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    let numOfSections = resultados.count > 0 ? 1 : 0
    if (numOfSections > 0)
    {
      tableView.backgroundView = nil
    }
    else
    {
      let noDataLabel: UILabel = UILabel(frame: CGRectMake(0, 0, self.tableView.bounds.size.width, self.tableView.bounds.size.height))
      noDataLabel.text = "No hay rutas"
      noDataLabel.textColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.5)
      noDataLabel.textAlignment = NSTextAlignment.Center
      tableView.backgroundView = noDataLabel
    }
    
    return numOfSections
  }
}

// MARK: UITableViewDelegate

extension RutasViewController: UITableViewDelegate {
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 62.0
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    dismissKeyboard()
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
  }
}

extension RutasViewController: UIScrollViewDelegate {
  
  func scrollViewWillBeginDragging(scrollView: UIScrollView) {
    searchBar.resignFirstResponder()
  }
}
