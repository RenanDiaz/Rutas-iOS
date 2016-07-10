//
//  RouteCell.swift
//  Rutas
//
//  Created by Renán Díaz Reyes on 7/5/16.
//  Copyright © 2016 Renán Díaz Reyes. All rights reserved.
//

import UIKit

protocol AsignationCellDelegate {
  
}

class AsignationCell: UITableViewCell {
  var delegate: AsignationCellDelegate?
  
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var subtitleLabel: UILabel!
}