//
//  ColorHelper.swift
//  PulsePolis
//
//  Created by IMAC  on 08.01.16.
//  Copyright © 2016 IMAC . All rights reserved.
//

import UIKit

class ColorHelper: NSObject {
    static let defaultColor = UIColor(red: 15.0/255.0, green: 211.0/255.0, blue: 219.0/255.0, alpha: 1.0)
    static func getColorByIndex(index: NSString) -> UIColor{
        switch(index){
        case "0":
            return UIColor(red: 0.0/255.0, green: 168.0/255.0, blue: 65.0/255.0, alpha: 1.0)
            
        case "1":
            return UIColor(red: 0.0/255.0, green: 168.0/255.0, blue: 65.0/255.0, alpha: 1.0)
            
        case "2":
            return UIColor(red: 135.0/255.0, green: 191.0/255.0, blue: 65.0/255.0, alpha: 1.0)
            
        case "3":
            return UIColor(red: 135.0/255.0, green: 191.0/255.0, blue: 65.0/255.0, alpha: 1.0)
            
        case "4":
            return UIColor(red: 255.0/255.0, green: 174.0/255.0, blue: 81.0/255.0, alpha: 1.0)
            
        case "5":
            return UIColor(red: 255.0/255.0, green: 174.0/255.0, blue: 81.0/255.0, alpha: 1.0)
            
        case "6":
            return UIColor(red: 255.0/255.0, green: 101.0/255.0, blue: 69.0/255.0, alpha: 1.0)
            
        case "7":
            return UIColor(red: 255.0/255.0, green: 101.0/255.0, blue: 69.0/255.0, alpha: 1.0)
            
        case "8":
            return UIColor(red: 255.0/255.0, green: 47.0/255.0, blue: 91.0/255.0, alpha: 1.0)
            
        case "9":
            return UIColor(red: 255.0/255.0, green: 47.0/255.0, blue: 91.0/255.0, alpha: 1.0)
            
        case "10":
            return UIColor(red: 255.0/255.0, green: 47.0/255.0, blue: 91.0/255.0, alpha: 1.0)
            
        default:
            return UIColor.clearColor()
        }
    }
    
}