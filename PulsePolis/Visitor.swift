//
//  Visitor.swift
//  PulsePolis
//
//  Created by IMAC  on 08.01.16.
//  Copyright © 2016 IMAC . All rights reserved.
//


import UIKit
import SwiftyJSON

class Visitor: NSObject {
    var id: Int?
    var sex: String?
    var name: String?
    var avatarUrl: String?
    var age: String?
    var checkin: String?
    
    init(json: JSON){
        self.id = json["id"].int
        self.sex = json["sex"].string
        self.name = json["name"].string
        self.avatarUrl = json["avatar_url"].string
        self.age = json["age"].string
        self.checkin = json["checkin"].string
        
    }
    
}