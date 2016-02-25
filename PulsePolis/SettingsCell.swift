
//
//  SettingsCell.swift
//  PulsePolis
//
//  Created by IMAC  on 07.02.16.
//  Copyright © 2016 IMAC . All rights reserved.
//

import UIKit



class SettingsCell: UITableViewCell {
    
    @IBOutlet var cityLabel: UILabel!
    
    //RangeSlider
    @IBOutlet var lowerLabelHorizontalConstraint: NSLayoutConstraint!
    @IBOutlet var upperLabelHorizontalConstraint: NSLayoutConstraint!
    @IBOutlet var rangeSlider: NMRangeSlider!
    
    @IBOutlet var upperLabel: UILabel!
    @IBOutlet var lowerLabel: UILabel!
    
    @IBOutlet var searchBar: UISearchBar!
    
    func configureRangeSlider(){
        self.configureLabelSlider()
        self.updateSliderLabels()
    }
    
    func configureLabelSlider(){
        rangeSlider.lowerHandleImageNormal = UIImage(named: "slider_thumb")
        rangeSlider.upperHandleImageNormal = UIImage(named: "slider_thumb")
        
        self.rangeSlider.minimumValue = 0;
        self.rangeSlider.maximumValue = 9;
        
        self.rangeSlider.setLowerValue(0, animated: false)
        self.rangeSlider.setUpperValue(9, animated: false)
        
        self.rangeSlider.minimumRange = 1
        
        self.rangeSlider.stepValue = 1
        self.rangeSlider.stepValueContinuously = true
    }
    
    func updateSliderLabels(){
        self.lowerLabelHorizontalConstraint.constant = self.rangeSlider.lowerCenter.x - self.lowerLabel.frame.width/2
        self.lowerLabel.text = "\(self.rangeSlider.lowerValue)"
        print(self.rangeSlider.lowerCenter)
        
        self.upperLabelHorizontalConstraint.constant = self.rangeSlider.upperCenter.x - self.upperLabel.frame.width/2
        self.upperLabel.text = "\(self.rangeSlider.upperValue)"
    }
    
    func configureSearchCell(){
        UISearchBar.appearance().backgroundColor = UIColor(red: 33.0/255.0, green: 40.0/255.0, blue: 47.0/255.0, alpha: 1.0)
        var txtField = searchBar.valueForKey("_searchField") as! UITextField
        txtField.backgroundColor = UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 0.3)
        txtField.textColor = UIColor(red: 235.0/255.0, green: 236.0/255.0, blue: 237.0/255.0, alpha: 0.3)
        //txtField.font = UIFont(name: "HelveticaNeue Thin", size: 11.0)
    }
    
    @IBAction func labelSliderChanged(sender: AnyObject) {
        self.updateSliderLabels()
    }
    
}
