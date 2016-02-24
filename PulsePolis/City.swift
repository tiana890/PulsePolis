//
//  City.swift
//  PulsePolis
//
//  Created by IMAC  on 05.01.16.
//  Copyright © 2016 IMAC . All rights reserved.
//

import UIKit
import SwiftyJSON

class City: NSObject {
    var id: String?
    var city: String?
    
    static func getCityFromDefaults() -> City?{
        let def = NSUserDefaults.standardUserDefaults()
        var c: City?
        
        if let cit = def.valueForKey("city") as? String{
            var tempCity = City()
            tempCity.city = cit
            if let ID = def.valueForKey("id") as? String{
                tempCity.id = ID
            }
            c = tempCity
        }
        
        return c
    }
    
    func saveCity(){
        let def = NSUserDefaults.standardUserDefaults()
        def.setValue(city, forKey: "city")
        def.setValue(id, forKey: "id")
        
        def.synchronize()
    }
    
    init(json: JSON){
        super.init()
        self.id = json["id"].string
        self.city = json["city"].string
    }
    
    init(_id: String, _name: String){
        super.init()
        
        self.id = _id
        self.city = _name
    }
    
    override init(){
        super.init()
    }
}
