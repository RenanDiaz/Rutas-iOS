//
//  RouteCell.swift
//  Rutas
//
//  Created by Renán Díaz Reyes on 7/5/16.
//  Copyright © 2016 Renán Díaz Reyes. All rights reserved.
//

import UIKit

protocol RouteCellDelegate {
  
}

class RouteCell: UITableViewCell {
  var delegate: RouteCellDelegate?
  
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var subtitleLabel: UILabel!
}