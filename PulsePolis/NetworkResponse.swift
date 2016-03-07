//
//  NetworkResponse.swift
//  PulsePolis
//
//  Created by IMAC  on 05.03.16.
//  Copyright © 2016 IMAC . All rights reserved.
//

import SwiftyJSON

class NetworkResponse: NSObject {
    
    var status: Status?
    var errMsg: String?
    
    override init() {
        super.init()
    }
    
    init(_status: String?, _errMsg: String?) {
        super.init()
        self.status = Status(rawValue: _status ?? "") ?? Status.Error
        self.errMsg = _errMsg
    
    }
}
