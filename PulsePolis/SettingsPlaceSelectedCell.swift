//
//  SettingsPlaceSelectedCell.swift
//  PulsePolis
//
//  Created by IMAC  on 12.12.15.
//  Copyright © 2015 IMAC . All rights reserved.
//

import UIKit

class SettingsPlaceSelectedCell: UITableViewCell {
    
    @IBOutlet var img: UIImageView!
    @IBOutlet var btn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if(selected){
            self.img.image = UIImage(named: "settings_place_circle_selected")
        } else {
            self.img.image = UIImage(named: "settings_place_circle")
        }
        // Configure the view for the selected state
    }
    
}
