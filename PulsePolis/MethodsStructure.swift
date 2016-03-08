//
//  MethodsStructure.swift
//  PulsePolis
//
//  Created by IMAC  on 05.03.16.
//  Copyright © 2016 IMAC . All rights reserved.
//

import Foundation
import SwiftyJSON

class MethodsStructure: NSObject {
    var dict = [String: String]()
    
    func getAuthURL() -> String{ return dict["auth"] ?? "" }
    func getCitiesURL() -> String{ return dict["cities"] ?? "" }
    func getCommentURL() -> String{ return dict["comment"] ?? "" }
    func getCommentsURL() -> String{ return dict["comments"] ?? "" }
    func getDefineCityURL() -> String{ return dict["definecity"] ?? "" }
    func getFavoritesURL() -> String{ return dict["favorites"] ?? "" }
    func getFeedbackURL() -> String{ return dict["feedback"] ?? "" }
    func getForecastURL() -> String{ return dict["forecast"] ?? "" }
    func getPlaceURL() -> String{ return dict["place"] ?? "" }
    func getPlacesURL() -> String{ return dict["places"] ?? ""}
    func getUserLocation() -> String{ return dict["userlocation"] ?? "" }
    func getVisitors() -> String{ return dict["visitors"] ?? "" }
    func getStat() -> String{ return dict["stat"] ?? "" }
    
    init(dictionary: [String: AnyObject]) {
        super.init()
        
        self.dict = dictionary as! [String: String]
    }
}
