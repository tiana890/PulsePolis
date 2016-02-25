//
//  SearchTableViewCell.swift
//  PulsePolis
//
//  Created by IMAC  on 14.12.15.
//  Copyright © 2015 IMAC . All rights reserved.
//

import UIKit


class SearchTableViewCell: UITableViewCell {
    
    @IBOutlet var btn: UIButton!
    @IBOutlet var name: UILabel!
    @IBOutlet var img: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        super.setSelected(selected, animated: animated)
        if(selected){
            self.img.image = UIImage(named: "fav_selected")
        } else {
            self.img.image = UIImage(named: "fav")
        }
        
        // Configure the view for the selected state
    }
    
}
