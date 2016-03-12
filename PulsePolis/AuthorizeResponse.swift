//
//  AuthorizeResponse.swift
//  PulsePolis
//
//  Created by IMAC  on 18.01.16.
//  Copyright © 2016 IMAC . All rights reserved.
//

import UIKit
import SwiftyJSON

class AuthorizeResponse: NetworkResponse {
    /*
    {
    "status" : "OK",
    "id" : 39
    "error": "Error text"
    }
    */
    var id: Int?
    var error: String?
    var token: String?
    
    init(json: JSON){
        super.init(_status: json["status"].string, _errMsg: json["errormsg"].string)
        self.id = json["id"].int
        self.error = json["error"].string
        print("TOKEN")
        
        self.token = json["token"].string
        print(self.token)
    }
}
