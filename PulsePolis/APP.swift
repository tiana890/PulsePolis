//
//  APP.swift
//  DBAccessInUse
//
//  Created by Agentum on 24.08.15.
//  Copyright (c) 2015 IMAC . All rights reserved.
//

//
//  APP.swift
//  DBAccessInUse
//
//  Created by Agentum on 24.08.15.
//  Copyright (c) 2015 IMAC . All rights reserved.
//

import UIKit
import RxSwift
import RxAlamofire
import SwiftyJSON

class APP{
    var user: User?{
        didSet{
            user?.saveUser()
        }
    }
    
    var city: City?    
    var containerController: ContainerViewController?
    
    var locationManager: LocationManager?
    
    var places:[Place] = []
    var refreshDate: NSDate?
    
    var cities:[City]?//{
    //        get{
    //            var array = [City(_id: 31, _name: "Екатеринбург"), City(_id: 3, _name: "Челябинск"), City(_id: 1, _name: "Москва"), City(_id: 2, _name: "Санкт-Петербург"), City(_id: 30, _name: "Омск")]
    //            return array
    //        }
    //}
    var disposeBag = DisposeBag()
    var ifLoading = false
    
    let sourceStringURL = "http://hotfinder.ru/hotjson/places.php?city_id="
    let citiesStringURL = "http://hotfinder.ru/hotjson/cities.php"
    
    var settingsManager: SettingsManager?
    
    static func i() -> APP{
        struct Static {
            static var onceToken : dispatch_once_t = 0
            static var instance : APP? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = APP()
            Static.instance?.locationManager = LocationManager()
            Static.instance?.user = User.getUserFromDefaults()
            Static.instance?.settingsManager = SettingsManager()
            Static.instance?.getCities()
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
    
    //MARK
    func getCities(){
        //        let parametersDict:[String: AnyObject] = ["user_id": APP.i().user?.userId ?? "", "lat": APP.i().locationManager?.location?.lat ?? "", "lon": APP.i().locationManager?.location?.lon ?? ""]
        
        
        requestData(.GET, citiesStringURL, parameters: nil, encoding: .URL, headers: nil)
            .observeOn(MainScheduler.instance)
            .debug()
            .subscribe({ (event) -> Void in
                if let element = event.element{
                    let data = element.1
                    print(JSON(data: data))
                }
            }).addDisposableTo(self.disposeBag)
        
        
    }
    
    func loadPlaces(){
        if(!ifLoading){
            ifLoading =  true
            
            print(sourceStringURL + "\(self.city!.id!)")
            requestJSON(.GET, sourceStringURL + "\(self.city!.id!)")
                .observeOn(MainScheduler.instance)
                .debug()
                .subscribe(onNext: { (r, json) -> Void in
                    let js = JSON(json)
                    print(r)
                    let status = js["status"]
                    
                    if (status == "OK"){
                        self.refreshDate = NSDate()
                        var arr = [Place]()
                        if let arrayOfPlaces = js["places"].array{
                            for (j) in arrayOfPlaces{
                                let place = Place(json: j)
                                arr.append(place)
                            }
                        }
                        self.places = arr
                        self.ifLoading = false
                        self.city?.saveCity()
                    } else {
                        //ERROR MSG
                        self.ifLoading = false
                    }
                    
                    }, onError: { (e) -> Void in
                        self.ifLoading = false
                        
                }).addDisposableTo(self.disposeBag)
        }
    }
    
    
}

