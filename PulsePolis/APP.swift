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
    
    var mainViewController: MainViewController?
    
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
            //Static.instance?.getCities()
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
    func getCities(handler: () -> Void){
        let networkClient = NetworkClient()
        
        let queue = dispatch_queue_create("initialqueue", nil)
        let concurrentScheduler = ConcurrentDispatchQueueScheduler(queue: queue)
        
       
        networkClient.getCities().observeOn(concurrentScheduler).subscribe(onNext: { (networkResponse) -> Void in
            self.getCitiesHandler(networkResponse)
            handler()
            }, onError: { (errorType) -> Void in
                self.updateSettings(networkClient, block: { () -> Void in
                    handler()
                })
            }, onCompleted: { () -> Void in
                
            }) { () -> Void in
                
            }.addDisposableTo(self.disposeBag)
        
        
        
    }
    
    func updateSettings(client: NetworkClient,block: () -> Void){
        let queue = dispatch_queue_create("updatequeue", nil)
        let concurrentScheduler = ConcurrentDispatchQueueScheduler(queue: queue)
        
        client.updateSettings().observeOn(concurrentScheduler).subscribe(onNext: { (response) -> Void in
            if(response.status == Status.Success){
                client.getCities().observeOn(concurrentScheduler).subscribeNext({ (citiesResponse) -> Void in
                    self.getCitiesHandler(citiesResponse)
                    block()
                }).addDisposableTo(self.disposeBag)
            } else {
                dispatch_async(dispatch_get_main_queue(), {
                    self.showAlert("Ошибка", msg: "Данные не могут быть загружены")
                })
            }
            }, onError: { (err) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    self.showAlert("Ошибка", msg: "Данные не могут быть загружены")
                })
                block()
            }, onCompleted: { () -> Void in
                
            }) { () -> Void in
                
        }.addDisposableTo(self.disposeBag)
    }
    
    func getCitiesHandler(citiesResponse:NetworkResponse){
        if let response = citiesResponse as? CitiesResponse{
            if(response.status == Status.Success){
                APP.i().cities = response.cities
            } else {
                dispatch_async(dispatch_get_main_queue(), {
                    self.showAlert("Ошибка", msg: "Данные не могут быть загружены")
                })

            }
        }
    }
    
    func defineCity(handler: () -> Void){
        let networkClient = NetworkClient()
        let queue = dispatch_queue_create("initialqueue", nil)
        let concurrentScheduler = ConcurrentDispatchQueueScheduler(queue: queue)
        
        networkClient.defineCity().observeOn(concurrentScheduler).subscribe(onNext: { (networkResponse) -> Void in
            self.defineCityHandler(networkResponse)
            handler()
            }, onError: { (errorType) -> Void in
                networkClient.updateSettings().observeOn(concurrentScheduler).subscribe(onNext: { (networkResponse) -> Void in
                    if(networkResponse.status == Status.Success){
                        networkClient.defineCity().debug().observeOn(concurrentScheduler).subscribeNext({ (defineCityResponse) -> Void in
                            self.defineCityHandler(defineCityResponse)
                            handler()
                        }).addDisposableTo(self.disposeBag)
                    } else {
                        dispatch_async(dispatch_get_main_queue(), {
                            self.showAlert("Ошибка", msg: "Данные не могут быть загружены")
                        })
                        
                    }
                }, onError: { (errType) -> Void in
                    handler()
                }, onCompleted: { () -> Void in
                    
                }, onDisposed: { () -> Void in
                    
                }).addDisposableTo(self.disposeBag)
            }, onCompleted: { () -> Void in
                
            }) { () -> Void in
                
        }.addDisposableTo(self.disposeBag)
    }

    func defineCityHandler(defineCityResponse: NetworkResponse){
        if let response = defineCityResponse as? DefineCityResponse{
            
            if(response.status == Status.Success){
                if let ifDefined = response.ifDefined{
                    if(ifDefined){
                        let city = City()
                        city.city = response.city
                        city.id = response.id
                        APP.i().city = city
                    }
                }
            } else {
                dispatch_async(dispatch_get_main_queue(), {
                    self.showAlert("Ошибка", msg: "Данные не могут быть загружены")
                })

            }
        }

    }
    
    func loadPlaces(){
        if(!ifLoading){
            ifLoading = true
            let queue = dispatch_queue_create("initialqueue", nil)
            let concurrentScheduler = ConcurrentDispatchQueueScheduler(queue: queue)
            
            let networkClient = NetworkClient()
            networkClient.getPlaces(self.city?.id ?? "").observeOn(concurrentScheduler).subscribe(onNext: { (networkResponse) -> Void in
                self.loadPlacesHandler(networkResponse)
                }, onError: { (errorType) -> Void in
    
                    networkClient.updateSettings().observeOn(concurrentScheduler).subscribeNext({ (networkResponse) -> Void in
                        if(networkResponse.status == Status.Success){
                            networkClient.getPlaces(self.city?.id ?? "").observeOn(concurrentScheduler).subscribeNext({ (placesResponse) -> Void in
                                self.loadPlacesHandler(placesResponse)
                            }).addDisposableTo(self.disposeBag)
                        } else {
                            dispatch_async(dispatch_get_main_queue(), {
                                self.showAlert("Ошибка", msg: "Данные не могут быть загружены")
                            })
                            
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
                dispatch_async(dispatch_get_main_queue(), {
                    self.showAlert("Ошибка", msg: "Данные не могут быть загружены")
                })


            }
        }
        self.ifLoading = false
    }
    
    //MARK: Alerts
    func showAlert(title: String, msg: String){
        let alert = UIAlertController(title: title,
            message: msg,
            preferredStyle: UIAlertControllerStyle.Alert)
        
        let cancelAction = UIAlertAction(title: "OK",
            style: .Cancel, handler: nil)
        
        alert.addAction(cancelAction)
        UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
        
    }
}

