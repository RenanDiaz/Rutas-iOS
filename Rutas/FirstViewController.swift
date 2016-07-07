//
//  FirstViewController.swift
//  Rutas
//
//  Created by Renán Díaz Reyes on 7/2/16.
//  Copyright © 2016 Renán Díaz Reyes. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {
  // 1
  let defaultSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
  // 2
  var dataTask: NSURLSessionDataTask?
  
  @IBOutlet weak var searchBar: UISearchBar!
  @IBOutlet weak var tableView: UITableView!
  
  var resultados = [Ruta]()
  
  lazy var tapRecognizer: UITapGestureRecognizer = {
    var recognizer = UITapGestureRecognizer(target:self, action: #selector(FirstViewController.dismissKeyboard))
    return recognizer
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.tableFooterView = UIView()
    self.cargarDatos()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  func actualizarDatos(data: NSData?) {
    resultados.removeAll()
    do {
      if let data = data, response = try NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions(rawValue:0)) as? [String: AnyObject] {
        // Get the results array
        if let array: AnyObject = response["rutas"] {
          for diccionarioDeRuta in array as! [AnyObject] {
            if let diccionarioDeRuta = diccionarioDeRuta as? [String: AnyObject], id = diccionarioDeRuta["id"] as? Int {
              let partida = diccionarioDeRuta["partida"] as? String
              let destino = diccionarioDeRuta["destino"] as? String
              let descripcion = diccionarioDeRuta["descripcion"] as? String
              resultados.append(Ruta(id: id, partida: partida, destino: destino, descripcion: descripcion))
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
    
    dispatch_async(dispatch_get_main_queue()) {
      self.tableView.reloadData()
      self.tableView.setContentOffset(CGPointZero, animated: false)
    }
  }
  
  func cargarDatos() {
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
  
  // MARK: Keyboard dismissal
  
  func dismissKeyboard() {
    searchBar.resignFirstResponder()
  }
}

// MARK: UISearchBarDelegate

extension FirstViewController: UISearchBarDelegate {
  
  func searchBarSearchButtonClicked(searchBar: UISearchBar) {
    // Dimiss the keyboard
    dismissKeyboard()
    
    if !searchBar.text!.isEmpty {
      if dataTask != nil {
        dataTask?.cancel()
      }
      
      UIApplication.sharedApplication().networkActivityIndicatorVisible = true
      
      let expectedCharSet = NSCharacterSet.URLQueryAllowedCharacterSet()
      let busqueda = searchBar.text!.stringByAddingPercentEncodingWithAllowedCharacters(expectedCharSet)!
      print("Busqueda: \(busqueda)")
      
      let url = NSURL(string: "http://190.141.120.200:8080/Rutas/rest/rutas?buscar=\(busqueda)")
      
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

  func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
    return .TopAttached
  }
  
  func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
    view.addGestureRecognizer(tapRecognizer)
  }
  
  func searchBarTextDidEndEditing(searchBar: UISearchBar) {
    view.removeGestureRecognizer(tapRecognizer)
  }
}

// MARK: RouteCellDelegate

extension FirstViewController: RouteCellDelegate {
  func openTapped(cell: RouteCell) {
    print(cell.titleLabel.text)
  }
}

// MARK: UITableViewDataSource

extension FirstViewController: UITableViewDataSource {
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return resultados.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("RouteCell", forIndexPath: indexPath) as!RouteCell
    
    cell.delegate = self
    
    let route = resultados[indexPath.row]
    
    cell.titleLabel.text = route.descripcion
    
    return cell
  }
}

// MARK: UITableViewDelegate

extension FirstViewController: UITableViewDelegate {
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 62.0
  }
}
