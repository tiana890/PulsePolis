//
//  User.swift
//  PulsePolis
//
//  Created by IMAC  on 29.11.15.
//  Copyright © 2015 IMAC . All rights reserved.
//

import UIKit

class User: NSObject {

    var name: String?
    var small_photo: UIImage?
    var age: NSNumber?
    //0 - not defined, 1- woman, 2- man
    var gender: Int = 0
    var photoURL: String?
    var photo: UIImage?
    
    var vkID: String?
    var facebookID: String?
    
    static func getUserFromDefaults() -> User?{
        let def = NSUserDefaults.standardUserDefaults()
        var u: User?
        
        if let n = def.valueForKey("name") as? String{
            u = User()
            u?.name = n
            if let vkid = def.valueForKey("vkID") as? String{
               u?.vkID = vkid
            }
            if let facebookid = def.valueForKey("facebookID") as? String{
                u?.facebookID = facebookid
            }
            if let ag = def.valueForKey("age") as? NSNumber{
                u?.age = ag
            }
            if let gend = def.valueForKey("gender") as? Int{
                u?.gender = gend
            }
            if let phURL = def.valueForKey("photoURL") as? String{
                u?.photoURL = phURL
            }
        }
        
        return u
    }
    
    func saveUser(){
        let def = NSUserDefaults.standardUserDefaults()
        def.setValue(name, forKey: "name")
        def.setValue(photoURL, forKey: "photoURL")
        def.setValue(gender, forKey: "gender")
        def.setValue(vkID, forKey: "vkID")
        def.setValue(facebookID, forKey: "facebookID")
        def.setValue(age, forKey: "age")
        def.synchronize()
    }
    
    func deleteUser(){
        let def = NSUserDefaults.standardUserDefaults()
        def.setValue(nil, forKey: "name")
        def.setValue(nil, forKey: "photoURL")
        def.setValue(nil, forKey: "gender")
        def.setValue(nil, forKey: "vkID")
        def.setValue(nil, forKey: "facebookID")
        def.setValue(nil, forKey: "age")
        def.synchronize()
        
        var u: User?
        APP.i().user = u
    }
}
