//
//  RutasViewController.swift
//  Rutas
//
//  Created by Renán Díaz Reyes on 7/2/16.
//  Copyright © 2016 Renán Díaz Reyes. All rights reserved.
//

import UIKit

class RutasViewController: UIViewController {
  
  let defaultSession = URLSession(configuration: URLSessionConfiguration.default)
  var dataTask: URLSessionDataTask?
  
  @IBOutlet weak var tableView: UITableView!
  var searchBar: UISearchBar!
  
  var rutas = [Ruta]()
  var resultados = [Ruta]()
  var cargar = true
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    if cargar {
      cargar = false
      tableView.tableFooterView = UIView()
      searchBar = UISearchBar.init(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: 44))
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
      
      UIApplication.shared.isNetworkActivityIndicatorVisible = true
      
      let url = URL(string: "http://190.141.120.200:8080/Rutas/rest/rutas")
      
      dataTask = defaultSession.dataTask(with: url!, completionHandler: {
        data, response, error in
        
        DispatchQueue.main.async {
          UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
        
        if let error = error {
          print(error.localizedDescription)
        } else if let httpResponse = response as? HTTPURLResponse {
          if httpResponse.statusCode == 200 {
            self.actualizarDatos(data)
          }
        }
      }) 
      
      dataTask?.resume()
    }
  }
  
  func actualizarDatos(_ data: Data?) {
    rutas.removeAll()
    do {
      if let data = data, let response = try JSONSerialization.jsonObject(with: data, options:JSONSerialization.ReadingOptions(rawValue:0)) as? [String: AnyObject] {
        // Get the results array
        if let array: AnyObject = response["rutas"] {
          for diccionarioDeRuta in array as! [AnyObject] {
            if let diccionarioDeRuta = diccionarioDeRuta as? [String: AnyObject], let id = diccionarioDeRuta["id"] as? Int {
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
    
    DispatchQueue.main.async {
      self.tableView.reloadData()
      self.tableView.setContentOffset(CGPoint(x: 0, y: 44), animated: false)
    }
  }
  
  // MARK: Keyboard dismissal
  
  func dismissKeyboard() {
    searchBar.resignFirstResponder()
  }
  
  // MARK: Segue
  
  let routeSegueIdentifier = "ShowRouteInfoSegue"
  
  // MARK: - Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if  segue.identifier == routeSegueIdentifier,
      let destination = segue.destination as? RouteInfoController,
      let routeIndex = tableView.indexPathForSelectedRow?.row
    {
      destination.ruta = resultados[routeIndex]
    }
  }
}

// MARK: UISearchBarDelegate

extension RutasViewController: UISearchBarDelegate {
  
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    
    dismissKeyboard()
  }
  
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    filterContentForSearchText(searchText)
  }

  func position(for bar: UIBarPositioning) -> UIBarPosition {
    return .topAttached
  }
  
  func filterContentForSearchText(_ searchText: String) {
    
    if self.rutas.count == 0 {
      self.resultados.removeAll()
      return
    }
    
    self.resultados = self.rutas.filter({( ruta: Ruta) -> Bool in
      var text = searchText
      if text.isEmpty {
        text = " "
      }
      return ruta.descripcion!.lowercased().range(of: text.lowercased()) != nil
    })
    
    DispatchQueue.main.async {
      self.tableView.reloadData()
      self.tableView.setContentOffset(CGPoint.zero, animated: false)
    }
  }
}

// MARK: UITableViewDataSource

extension RutasViewController: UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return resultados.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "RouteCell", for: indexPath) as!RouteCell
    
    let route = resultados[indexPath.row]
    
    cell.titleLabel.text = route.descripcion
    cell.subtitleLabel.text = String(route.id!)
    
    return cell
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    let numOfSections = resultados.count > 0 ? 1 : 0
    if (numOfSections > 0)
    {
      tableView.backgroundView = nil
    }
    else
    {
      let noDataLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: self.tableView.bounds.size.height))
      noDataLabel.text = "No hay rutas"
      noDataLabel.textColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.5)
      noDataLabel.textAlignment = NSTextAlignment.center
      tableView.backgroundView = noDataLabel
    }
    
    return numOfSections
  }
}

// MARK: UITableViewDelegate

extension RutasViewController: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 62.0
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    dismissKeyboard()
    tableView.deselectRow(at: indexPath, animated: true)
  }
}

extension RutasViewController: UIScrollViewDelegate {
  
  func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    searchBar.resignFirstResponder()
  }
}
