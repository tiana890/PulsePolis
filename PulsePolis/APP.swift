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
import Mapbox

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
    
    var settingsManager: SettingsManager?
    
    var networkManager: NetworkManager?
    
    var mapView: MGLMapView?
    
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
        
        networkClient.updateSettings().observeOn(MainScheduler.instance).subscribeNext { (response) -> Void in
            networkClient.getCities().observeOn(MainScheduler.instance).subscribe(onNext: { (networkResponse) -> Void in
                self.getCitiesHandler(networkResponse)
                }, onError: { (errorType) -> Void in
                    networkClient.updateSettings().observeOn(MainScheduler.instance).subscribeNext({ (response) -> Void in
                        if(response.status == Status.Success){
                            networkClient.getCities().observeOn(MainScheduler.instance).subscribeNext({ (citiesResponse) -> Void in
                                
                                self.getCitiesHandler(citiesResponse)
                            }).addDisposableTo(self.disposeBag)
                        } else {
                            //ALERT!!!!
                        }
                    }).addDisposableTo(self.disposeBag)
                }, onCompleted: { () -> Void in
                    
                }) { () -> Void in
                    
                }.addDisposableTo(self.disposeBag)
        }.addDisposableTo(self.disposeBag)
       
        
    }
    
    func getCitiesHandler(citiesResponse:NetworkResponse){
        if let response = citiesResponse as? CitiesResponse{
            if(response.status == Status.Success){
                APP.i().cities = response.cities
            } else {
                 //ALERT!!!
            }
        }

    }
    
    func defineCity(handler: () -> Void){
        let networkClient = NetworkClient()
        
        networkClient.defineCity().observeOn(MainScheduler.instance).subscribe(onNext: { (networkResponse) -> Void in
            self.defineCityHandler(networkResponse)
            handler()
            }, onError: { (errorType) -> Void in
                networkClient.updateSettings().observeOn(MainScheduler.instance).subscribeNext({ (response) -> Void in
                    if(response.status == Status.Success){
                        networkClient.defineCity().observeOn(MainScheduler.instance).subscribeNext({ (defineCityResponse) -> Void in
                            self.defineCityHandler(defineCityResponse)
                        }).addDisposableTo(self.disposeBag)
                    } else {
                        //ALERT!!!!
                    }
                    handler()
                }).addDisposableTo(self.disposeBag)
            }, onCompleted: { () -> Void in
                
            }) { () -> Void in
                
        }.addDisposableTo(self.disposeBag)
    }

    func defineCityHandler(defineCityResponse: NetworkResponse){
        if let response = defineCityResponse as? DefineCityResponse{
            if(response.status == Status.Success){
                let city = City()
                city.city = response.city
                city.id = response.id
                APP.i().city = city
            } else {
                //ALERT!!!
            }
        }

    }
    
    func loadPlaces(){
        if(!ifLoading){
            ifLoading = true
            let networkClient = NetworkClient()
            networkClient.getPlaces(self.city?.id ?? "").observeOn(MainScheduler.instance).subscribe(onNext: { (networkResponse) -> Void in
                self.loadPlacesHandler(networkResponse)
                }, onError: { (errorType) -> Void in
                    networkClient.updateSettings().observeOn(MainScheduler.instance).subscribeNext({ (networkResponse) -> Void in
                        if(networkResponse.status == Status.Success){
                            networkClient.getPlaces(self.city?.id ?? "").observeOn(MainScheduler.instance).subscribeNext({ (placesResponse) -> Void in
                                self.loadPlacesHandler(placesResponse)
                            }).addDisposableTo(self.disposeBag)
                        } else {
                            //ALERT!!!!
                            
                        }

                    }).addDisposableTo(self.disposeBag)
                }, onCompleted: { () -> Void in
                    self.ifLoading = false
                }, onDisposed: { () -> Void in
                    
            }).addDisposableTo(self.disposeBag)
        }
    }
    
    func loadPlacesHandler(placesResponse: NetworkResponse){
        if let response = placesResponse as? PlacesResponse{
            if(response.status == Status.Success){
                if let _places = response.places{
                    APP.i().places = _places
                }
            } else {
                //ALERT!!!

            }
        }
        self.ifLoading = false
    }
    
    
}

