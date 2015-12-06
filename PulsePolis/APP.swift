//
//  APP.swift
//  DBAccessInUse
//
//  Created by Agentum on 24.08.15.
//  Copyright (c) 2015 IMAC . All rights reserved.
//

import UIKit



class APP{
    
    var user: User?{
        didSet{
            user?.saveUser()
        }
    }
    var containerController: ContainerViewController?
    
    static func i() -> APP{
        struct Static {
            static var onceToken : dispatch_once_t = 0
            static var instance : APP? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = APP()
                   }
        return Static.instance!
    }
    
    func showCenterPanel(){
        containerController?.animatedPanelMoveViewToLeftEdge()
    }
    
    func hideCenterPanel(){
        containerController?.animatedPanelMoveViewToLeftEdge()
    }
    
    func moveCenterPanel(){
        containerController?.moveCenterPanel()
    }
    
}

