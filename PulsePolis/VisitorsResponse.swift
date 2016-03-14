//
//  VisitorsResponse.swift
//  PulsePolis
//
//  Created by IMAC  on 11.03.16.
//  Copyright © 2016 IMAC . All rights reserved.
//

import SwiftyJSON

class VisitorsResponse: NetworkResponse {
    var visitors: [Visitor]?
    
    override init(json: JSON){
        super.init(_status: json["status"].string, _errMsg: json["errormsg"].string)
        self.visitors = [Visitor]()
        for(var i = 0; i < json["visitors"].array?.count; i++){
            let json = json["visitors"].array![i]
            self.visitors?.append(Visitor(json: json))
        }
        
    }
}
