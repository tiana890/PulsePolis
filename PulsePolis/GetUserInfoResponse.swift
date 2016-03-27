//
//  GetUserInfoResponse.swift
//  PulsePolis
//
//  Created by IMAC  on 27.03.16.
//  Copyright © 2016 IMAC . All rights reserved.
//

import UIKit
import SwiftyJSON

class GetUserInfoResponse: NetworkResponse {
    /*
    "id":"123456",
    "name":"test_user",
    "age":"0",
    "sex":"man",
    "photo":"http:\/\/img3.goodfon.ru\/original\/640x480\/5\/24\/obey-podchinyaysya-graffiti.jpg",
    "type":"vk",
    "token":"blS3mP8IjuGiXLOMBhKRFVxfdvApJ97rUC10H5oY2NgWqkascn",
    */
    
    var id: String?
    var name: String?
    var age: Int?
    var sex: String?
    var photo: String?
    var type: String?
    var token: String?
    
    override init(json: JSON){
        super.init(_status: json["status"].string, _errMsg: json["errormsg"].string)
        self.id = json["id"].string
        self.name = json["name"].string
        self.sex = json["sex"].string
        self.age = json["age"].int
        self.photo = json["photo"].string
        self.type = json["type"].string
        self.token = json["token"].string
    }

    
}
