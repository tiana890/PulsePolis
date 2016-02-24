//
//  DefineCityResponse.swift
//  PulsePolis
//
//  Created by IMAC  on 18.01.16.
//  Copyright © 2016 IMAC . All rights reserved.
//

import UIKit
import SwiftyJSON

class DefineCityResponse: NSObject {
    /*
    {
    "status" : "OK",
    "id" : 39
    "error": "Error text"
    }
    */
    var status: String?
    var id: String?
    var city: String?
    var ifDefined: Bool?
    
    init(json: JSON){
        self.status = json["status"].string
        self.id = json["id"].string
        self.ifDefined = json["ifDefined"].bool
        self.city = json["city"].string
    }
}
