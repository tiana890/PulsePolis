//
//  AuthorizeResponse.swift
//  PulsePolis
//
//  Created by IMAC  on 18.01.16.
//  Copyright © 2016 IMAC . All rights reserved.
//

import UIKit
import SwiftyJSON

class AuthorizeResponse: NSObject {
    /*
    {
    "status" : "OK",
    "id" : 39
    "error": "Error text"
    }
    */
    var status: String?
    var id: Int?
    var error: String?
    
    init(json: JSON){
        self.status = json["status"].string
        self.id = json["id"].int
        self.error = json["error"].string
    }
}
