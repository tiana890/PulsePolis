//
//  NetworkManager.swift
//  PulsePolis
//
//  Created by IMAC  on 05.03.16.
//  Copyright © 2016 IMAC . All rights reserved.
//

import RxSwift
import RxAlamofire

class NetworkManager: NSObject {

    var token: String?
    var version: String?
    var domain: String?
    var methodsStructure: MethodsStructure?
}
