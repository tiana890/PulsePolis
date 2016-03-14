//
//  PlacesResponse.swift
//  PulsePolis
//
//  Created by IMAC  on 05.03.16.
//  Copyright © 2016 IMAC . All rights reserved.
//

import SwiftyJSON

class PlacesResponse: NetworkResponse {
    var places: [Place]?
    
    override init(json: JSON){
        super.init(_status: json["status"].string, _errMsg: json["errormsg"].string)
        self.places = [Place]()
        for(var i = 0; i < json["places"].array?.count; i++){
            let json = json["places"].array![i]
            self.places?.append(Place(json: json))
        }
        
    }
}
