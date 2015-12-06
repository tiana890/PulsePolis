//
//  TodayStatisticsCell.swift
//  PulsePolis
//
//  Created by IMAC  on 29.11.15.
//  Copyright © 2015 IMAC . All rights reserved.
//

import UIKit

class TodayStatisticsCell: UITableViewCell {

    @IBOutlet var daysSegmentedControl: UISegmentedControl!
    @IBOutlet var segmentedControl: UISegmentedControl!
    override func awakeFromNib() {
        super.awakeFromNib()
       
        
        UISegmentedControl.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.whiteColor()], forState: UIControlState.Normal)
         UISegmentedControl.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.whiteColor()], forState: UIControlState.Selected)
        segmentedControl.tintColor = UIColor(red: 41/255, green: 116/255, blue: 124/255, alpha: 0.54)
        
        daysSegmentedControl.tintColor = UIColor.clearColor()
        
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
