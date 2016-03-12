//
//  User.swift
//  PulsePolis
//
//  Created by IMAC  on 29.11.15.
//  Copyright © 2015 IMAC . All rights reserved.
//

import UIKit
import SwiftyJSON

class User: NSObject {
    var firstName: String?
    var lastName: String?
    
    var age: NSNumber?
    //0 - not defined, 1- woman, 2- man
    var gender: Gender = .None
    var photoURL: String?
    
    var authorizeType: AuthorizeType?
    var vkID: String?
    var facebookID: String?
    
    var auth: String?
    
    var token: String?
    var userId: Int?{
        didSet{
            self.saveUser()
        }
    }
    
    func getSocialId() -> String?{
        print(self.auth)
        if (self.auth == "facebook"){
            return self.facebookID
        } else {
            return self.vkID
        }
    }
    
    init(jsonFromFacebook: JSON) {
        super.init()
        /*
        {
        "first_name" : "Zaytseva",
        "last_name" : "Marina",
        "id" : "538085733007579",
        "age_range" : {
        "min" : 21
        },
        "gender" : "female",
        "picture" : {
        "data" : {
        "width" : 200,
        "url" : "https:\/\/scontent.xx.fbcdn.net\/hprofile-xfa1\/v\/t1.0-1\/p200x200\/11164785_465435746939245_9071997927249509104_n.jpg?oh=46830c80d54a314eb2a6372fcf3bb439&oe=573DEE06",
        "is_silhouette" : false,
        "height" : 200
        }
        }
        }
        */
        self.firstName = jsonFromFacebook["first_name"].string
        self.lastName = jsonFromFacebook["last_name"].string
        self.facebookID = jsonFromFacebook["id"].string
        
        if let gender = jsonFromFacebook["gender"].string{
            switch(gender){
            case "female":
                self.gender = Gender.Female
                break
            case "male":
                self.gender = Gender.Male
                break
            default:
                self.gender = Gender.None
                break
            }
        }
        
        if let url = jsonFromFacebook["picture"]["data"]["url"].string{
            self.photoURL = url
        }
        
        self.authorizeType = AuthorizeType.Facebook
        self.auth = "facebook"
        
    }
    
    init(jsonFromVK: JSON){
        super.init()
        /*
        {
        bdate = "15.4";
        "first_name" = Marina;
        id = 143900400;
        "last_name" = Zaytseva;
        "photo_200" = "https://pp.vk.me/c622929/v622929400/4c68e/fP1ttZxXlDo.jpg";
        sex = 1;
        }
        */
        print(jsonFromVK)
        var array = jsonFromVK.array
        if(array?.isEmpty == false){
            self.firstName = array?[0]["first_name"].string
            self.lastName = array?[0]["last_name"].string
            self.vkID = "\(array?[0]["id"].int64 ?? 0)"
            print(self.vkID)
            self.photoURL = array?[0]["photo_200"].string
            
            if let gender = array?[0]["sex"].int{
                if(gender == 1){
                    self.gender = Gender.Female
                } else if(gender == 2){
                    self.gender = Gender.Male
                } else {
                    self.gender = Gender.None
                }
            }
            self.authorizeType = AuthorizeType.VK
            self.auth = "vk"
        }
    }
    
    override init(){
        super.init()
    }
    
    static func getUserFromDefaults() -> User?{
        let def = NSUserDefaults.standardUserDefaults()
        var u: User?
        
        if let fName = def.objectForKey("firstName") as? String{
            u = User()
            u?.firstName = fName
            
            if let lName = def.objectForKey("lastName") as? String{
                u?.lastName = lName
            }
            if let vkid = def.objectForKey("vkID") as? String{
                u?.vkID = vkid
            }
            if let facebookid = def.objectForKey("facebookID") as? String{
                u?.facebookID = facebookid
            }
            if let ag = def.objectForKey("age") as? NSNumber{
                u?.age = ag
            }
            if let gend = def.objectForKey("gender") as? Int{
                if let newGender = Gender(rawValue: gend){
                    u?.gender = newGender
                }
            }
            if let phURL = def.objectForKey("photoURL") as? String{
                u?.photoURL = phURL
            }
            if let id = def.objectForKey("userID") as? Int{
                u?.userId = id
            }
            if let authType = def.objectForKey("auth") as? String{
                u?.auth = authType
                u?.authorizeType = AuthorizeType(rawValue: authType)
//                if let newAuthType = AuthorizeType(rawValue: authType){
//                    u?.authorizeType = newAuthType
//                }
            }
            if let tok = def.objectForKey("token") as? String{
                u?.token = tok
            }

        }
        
        return u
    }
    
    func saveUser(){
        let def = NSUserDefaults.standardUserDefaults()
        if let fName = self.firstName{
            def.setObject(fName, forKey: "firstName")
        }
        if let lName = self.lastName{
            def.setObject(lName, forKey: "lastName")
        }
        if let phURL = self.photoURL{
            def.setObject(phURL, forKey: "photoURL")
        }
        
        def.setObject(gender.rawValue, forKey: "gender")
        
        if let vId = self.vkID{
            def.setObject(vId, forKey: "vkID")
        }
        if let fId = self.facebookID{
            def.setValue(fId, forKey: "facebookID")
        }
        if let ag = self.age{
            def.setObject(ag, forKey: "age")
        }
        if let uId = self.userId{
            def.setObject(uId, forKey: "userID")
        }
        if let aut = self.auth{
            def.setObject(aut, forKey: "auth")
        }
        if let tok = self.token{
            def.setObject(tok, forKey: "token")
        }
        def.synchronize()
    }
    
    func deleteUser(){
        let def = NSUserDefaults.standardUserDefaults()
        
        def.removeObjectForKey("firstName")
        def.removeObjectForKey("lastName")
        def.removeObjectForKey("photoURL")
        def.removeObjectForKey("gender")
        def.removeObjectForKey("vkID")
        def.removeObjectForKey("facebookID")
        def.removeObjectForKey("age")
        def.removeObjectForKey("userID")
        def.removeObjectForKey("auth")
        def.removeObjectForKey("token")
        
        def.synchronize()
        
        var u: User?
        APP.i().user = u
    }
    
    
}
