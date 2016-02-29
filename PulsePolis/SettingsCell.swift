
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
        
        self.rangeSlider.minimumValue = 0
        self.rangeSlider.maximumValue = 10
        
        self.rangeSlider.setExplicitLower(Float(APP.i().settingsManager!.lowerIndex))
        self.rangeSlider.setUpperValue(Float(APP.i().settingsManager!.upperIndex), animated: false)
        
        self.rangeSlider.minimumRange = 1
        
        self.rangeSlider.stepValue = 1
        self.rangeSlider.stepValueContinuously = true
    }
    
    func updateSliderLabels(){
        self.rangeSlider.layoutSubviews()
        
        self.lowerLabelHorizontalConstraint.constant = self.rangeSlider.lowerCenter.x - self.lowerLabel.frame.width/2
        self.lowerLabel.text = "\(Int(self.rangeSlider.lowerValue))"
        
        
        if(Int(self.rangeSlider.upperValue) == 10){
            self.upperLabelHorizontalConstraint.constant = self.rangeSlider.upperCenter.x - self.upperLabel.frame.width/2
            
        } else {
            self.upperLabelHorizontalConstraint.constant = self.rangeSlider.upperCenter.x - self.upperLabel.frame.width/4
        }
        
        self.upperLabel.text = "\(Int(self.rangeSlider.upperValue))"
        print("upperConstraintConstant = \(self.upperLabelHorizontalConstraint.constant)")
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
        APP.i().settingsManager?.lowerIndex = Int(self.rangeSlider.lowerValue)
        APP.i().settingsManager?.upperIndex = Int(self.rangeSlider.upperValue)
    }
    
}
