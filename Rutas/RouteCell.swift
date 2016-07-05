//
//  RouteCell.swift
//  Rutas
//
//  Created by Renán Díaz Reyes on 7/5/16.
//  Copyright © 2016 Renán Díaz Reyes. All rights reserved.
//

import UIKit

protocol RouteCellDelegate {
  func openTapped(cell: RouteCell)
}

class RouteCell: UITableViewCell {
  var delegate: RouteCellDelegate?
  
  @IBOutlet weak var titleLabel: UILabel!
  
  @IBAction func openTapped(sender: AnyObject) {
    delegate?.openTapped(self)
  }
}