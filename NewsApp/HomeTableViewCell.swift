//
//  CustomTableViewCell.swift
//  NewsApp
//
//  Created by Matheus Matsumoto on 08/07/22.
//

import UIKit

class HomeTableViewCell: UITableViewCell {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var goButton: UIButton!
    
    var url: String?
    
}
