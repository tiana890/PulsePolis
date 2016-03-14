//
//  CitiesResponse.swift
//  PulsePolis
//
//  Created by IMAC  on 21.02.16.
//  Copyright © 2016 IMAC . All rights reserved.
//

import UIKit
import SwiftyJSON

class CitiesResponse: NetworkResponse {
    var cities: [City]?
    
    //    "cities" : [
    //    {
    //    "city" : "Москва",
    //    "id" : "1"
    //    },
    //    {
    //    "city" : "Санкт-Петербург",
    //    "id" : "2"
    //    },
    //    {
    //    "city" : "Челябинск",
    //    "id" : "3"
    //    },
    //    {
    //    "city" : "Омск",
    //    "id" : "30"
    //    },
    //    {
    //    "city" : "Екатеринбург",
    //    "id" : "31"
    //    },
    //    {
    //    "city" : "Иерусалим",
    //    "id" : "32"
    //    }
    //    ],
    //    "status" : "OK"
    
    override init(json: JSON){
        super.init(_status: json["status"].string, _errMsg: json["errormsg"].string)
        self.cities = [City]()
        for(var i = 0; i < json["cities"].array?.count; i++){
            let json = json["cities"].array![i]
            self.cities?.append(City(json: json))
        }
        
    }
}
