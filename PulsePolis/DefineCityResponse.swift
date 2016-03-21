//
//  DefineCityResponse.swift
//  PulsePolis
//
//  Created by IMAC  on 18.01.16.
//  Copyright © 2016 IMAC . All rights reserved.
//

import UIKit
import SwiftyJSON

class DefineCityResponse: NetworkResponse{
    /*
    {
    "status" : "OK",
    "id" : 39
    "error": "Error text"
    }
    */
    var id: String?
    var city: String?
    var ifDefined: Bool?
    
    override init(json: JSON){
        super.init(_status: json["status"].string, _errMsg: json["errormsg"].string)
        self.id = json["id"].string
        self.ifDefined = false
        if let intIfDefinedValue = json["ifDefined"].int{
            if(intIfDefinedValue == 0){
                self.ifDefined = false
            } else {
                self.ifDefined = true
            }
        }
        self.city = json["city"].string
    }
}
