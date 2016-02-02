//
//  PreferencesManager.swift
//  PulsePolis
//
//  Created by IMAC  on 02.02.16.
//  Copyright © 2016 IMAC . All rights reserved.
//

//
//  PreferencesManager.swift
//  GBU
//
//  Created by Agentum on 13.01.16.
//  Copyright © 2016 IMAC . All rights reserved.
//

import Foundation

class FavoritesManager: NSObject {
    
    func saveFavoriteId(placeId: Int){
        let def = NSUserDefaults.standardUserDefaults()
        var array = [Int]()
        if let arrayOfFavIds = def.objectForKey("favIds") as? [Int]{
            array.appendContentsOf(arrayOfFavIds)
            if(!arrayOfFavIds.contains(placeId)){
                array.append(placeId)
            }
        } else {
            array.append(placeId)
        }
        def.setObject(array, forKey: "favIds")
        def.synchronize()
    }
    
    func getFavouriteIds() -> [Int]{
        let def = NSUserDefaults.standardUserDefaults()
        var array = [Int]()
        if let arrayOfFavIds = def.objectForKey("favIds") as? [Int]{
            array.appendContentsOf(arrayOfFavIds)
        }
        return array
    }
    
    func removeFromFavorites(placeId: Int){
        let def = NSUserDefaults.standardUserDefaults()
        
        if let arrayOfFavIds = def.objectForKey("favIds") as? [Int]{
            if let index = arrayOfFavIds.indexOf(placeId){
                var newArray = arrayOfFavIds
                newArray.removeAtIndex(index)
                def.setObject(newArray, forKey: "favIds")
                def.synchronize()
            }
        }
    }
    
    func favContainsPlace(placeId: Int) -> Bool{
        let def = NSUserDefaults.standardUserDefaults()
        if let arrayOfFavIds = def.objectForKey("favIds") as? [Int]{
            if(arrayOfFavIds.contains(placeId)){
                return true
            }
        }
        return false
    }
}

