//
//  CityResponse.swift
//  PulsePolis
//
//  Created by IMAC  on 06.02.16.
//  Copyright © 2016 IMAC . All rights reserved.
//
import UIKit
import SwiftyJSON

class CityResponse: NSObject {
    //
    //    {
    //    "4" : {
    //    "city" : "Екатеринбург",
    //    "id" : "31"
    //    },
    //    "status" : "OK",
    //    "2" : {
    //    "city" : "Челябинск",
    //    "id" : "3"
    //    },
    //    "0" : {
    //    "city" : "Москва",
    //    "id" : "1"
    //    },
    //    "5" : {
    //    "city" : "Иерусалим",
    //    "id" : "32"
    //    },
    //    "1" : {
    //    "city" : "Санкт-Петербург",
    //    "id" : "2"
    //    },
    //    "3" : {
    //    "city" : "Омск",
    //    "id" : "30"
    //    }
    //    }
    
    var status: String?
    var cities: [City]?
    
    init(json: JSON) {
        self.status = json["status"].string
        
    }
}
