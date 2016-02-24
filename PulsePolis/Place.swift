//
//  Place.swift
//  PulsePolis
//
//  Created by IMAC  on 06.01.16.
//  Copyright © 2016 IMAC . All rights reserved.
//


import UIKit
import SwiftyJSON

class Place: NSObject {
    var id: String?
    var visitIndex: String?
    var lat: String?
    var lon: String?
    var name: String?
    var address: String?
    var cocktailPrice: String?
    var placeType: String?
    var man: Int?
    var woman: Int?
    
    init(json: JSON){
        self.id = json["id"].string
        self.visitIndex = json["visit_index"].string
        self.lat = json["cord"]["lat"].string
        self.lon = json["cord"]["lon"].string
        self.name = json["place_info"]["name"].string
        self.address = json["place_info"]["address"].string
        self.cocktailPrice = json["place_info"]["cocktail_price"].string
        self.placeType = json["place_info"]["place_type"].string
        self.man = json["place_info"]["man"].int
        self.woman = json["place_info"]["woman"].int
    }
}