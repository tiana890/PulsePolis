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
    
    var city: City? {
        didSet{
            self.places.removeAll()
            loadPlaces()
        }
    }
    
    var containerController: ContainerViewController?
    
    var locationManager: LocationManager?
    
    var places:[Place] = []
    var refreshDate: NSDate?
    
    var cities:[City]?
    var disposeBag = DisposeBag()
    var ifLoading = false
    
    
    let sourceStringURL = "http://hotfinder.ru/hotjson/v1.0/places.php?city_id="
    let citiesStringURL = "http://hotfinder.ru/hotjson/v1.0/cities.php"
    let postLocationCoordinates = "http://hotfinder.ru/hotjson/v1.0/definecity.php"
    
    var settingsManager: SettingsManager?
    
    var networkManager: NetworkManager?
    
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
            Static.instance?.networkManager = NetworkManager()
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
    
    
    
    //MARK: methods
    func getCities(){
        let networkClient = NetworkClient()
        networkClient.updateSettings().observeOn(MainScheduler.instance).subscribeNext { (networkResponse) -> Void in
            if(networkResponse.status == Status.Success){
                networkClient.getCities().observeOn(MainScheduler.instance).subscribeNext({ (response) -> Void in
                    if let citiesResponse = response as? CitiesResponse{
                        if(citiesResponse.status == Status.Success){
                            APP.i().cities = citiesResponse.cities
                        } else {
                             //ALERT!!!
                        }
                    }
                }).addDisposableTo(self.disposeBag)
            } else{
                //ALERT!!!
            }
        }.addDisposableTo(self.disposeBag)

    }
    
    func defineCity(handler: () -> Void){
        let networkClient = NetworkClient()
        networkClient.updateSettings().observeOn(MainScheduler.instance).subscribeNext { (networkResponse) -> Void in
            if(networkResponse.status == Status.Success){
                networkClient.defineCity().observeOn(MainScheduler.instance).subscribeNext({ (response) -> Void in
                    if let defineCityResponse = response as? DefineCityResponse{
                        if(defineCityResponse.status == Status.Success){
                            let city = City()
                            city.city = defineCityResponse.city
                            city.id = defineCityResponse.id
                            APP.i().city = city
                        } else {
                            //ALERT!!!
                        }
                    }
                    handler()
                }).addDisposableTo(self.disposeBag)
            } else{
                //ALERT!!!
            }
            }.addDisposableTo(self.disposeBag)
    }

    
    func loadPlaces(){
        if(!ifLoading){
            ifLoading = true
            let networkClient = NetworkClient()
            networkClient.updateSettings().observeOn(MainScheduler.instance).subscribeNext { (networkResponse) -> Void in
                if(networkResponse.status == Status.Success){
                    networkClient.getPlaces(self.city?.id ?? "").observeOn(MainScheduler.instance).subscribeNext({ (response) -> Void in
                        if let placesResponse = response as? PlacesResponse{
                            if(placesResponse.status == Status.Success){
                                if let _places = placesResponse.places{
                                    APP.i().places = _places
                                }
                            } else {
                                //ALERT!!!
                               
                            }
                        }
                        self.ifLoading = false
                    }).addDisposableTo(self.disposeBag)
                } else{
                    //ALERT!!!
                    self.ifLoading = false
                }
                }.addDisposableTo(self.disposeBag)
        }
    }
    
    
}

