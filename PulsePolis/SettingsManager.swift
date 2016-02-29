//
//  SettingsManager.swift
//  PulsePolis
//
//  Created by IMAC  on 11.02.16.
//  Copyright © 2016 IMAC . All rights reserved.
//

//
//  SettingsManager.swift
//  PulsePolis
//
//  Created by IMAC  on 11.02.16.
//  Copyright © 2016 IMAC . All rights reserved.
//

import UIKit

class SettingsManager: NSObject {
    
    var lowerIndex = 0
    var upperIndex = 10
    
    var placeTypes = [String]()
    
    func isValid(place: Place) -> Bool{
        if let visitIndex = place.visitIndex{
            if(Int(visitIndex) >= self.lowerIndex && Int(visitIndex) <= self.upperIndex){
                if (self.placeTypes.isEmpty){
                    return true
                } else {
                    if let placeType = place.placeType{
                        if (self.placeTypes.contains(placeType)){
                            return true
                        }
                    }
                }
            }
        }
        return false
    }
    
    func ifContainsPlaceType(type: String) -> Bool{
        return self.placeTypes.contains(type)
    }
    
    func appendOrRemovePlaceType(type: String){
        if(self.placeTypes.contains(type)){
            self.placeTypes.removeAtIndex(self.placeTypes.indexOf(type)!)
        } else {
            self.placeTypes.append(type)
        }
        
    }
}
