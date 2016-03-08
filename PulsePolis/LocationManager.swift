//
//  LocationManager.swift
//  PulsePolis
//
//  Created by IMAC  on 07.12.15.
//  Copyright © 2015 IMAC . All rights reserved.
//

import UIKit
import CoreLocation
import RxAlamofire
import RxSwift
import SwiftyJSON

class LocationManager: NSObject, CLLocationManagerDelegate {
    var locationManager: CLLocationManager?
    var locationCoordinate: CLLocationCoordinate2D?{
        get{
            return locationManager?.location?.coordinate
        }
    }
//    var delegate: LocationManagerProtocol?
    
    var prevLocation: CLLocation?
    var disposeBag = DisposeBag()
    var isAvailable: Bool{
        get{
            let status = CLLocationManager.authorizationStatus()
            if(status ==  CLAuthorizationStatus.Denied || status == CLAuthorizationStatus.AuthorizedWhenInUse){
                return false
            } else {
                return true
            }
        }
    }
    
    var location: (lat: Double, lon: Double)?{
        get{
            var returnLocation: (Double, Double)?
            if let loc = self.locationManager?.location?.coordinate{
                return (loc.latitude, loc.longitude)
            } else {
                return returnLocation
            }
        }
    }
    
    override init() {
        super.init()
        if (self.locationManager == nil){
            self.locationManager = CLLocationManager()
        }
        self.locationManager?.delegate = self
        self.locationManager?.requestWhenInUseAuthorization()
        self.locationManager?.desiredAccuracy = kCLLocationAccuracyHundredMeters
        
        self.locationManager?.distanceFilter = 500
        self.locationManager?.allowsBackgroundLocationUpdates = true

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "inBackground", name: UIApplicationDidEnterBackgroundNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "inForeground", name: UIApplicationDidBecomeActiveNotification, object: nil)
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    func inBackground()
    {
        self.locationManager?.startMonitoringSignificantLocationChanges()
        self.locationManager?.stopUpdatingLocation()
    }
    func inForeground()
    {
//        self.locationManager?.startMonitoringSignificantLocationChanges()
//        self.locationManager?.stopUpdatingLocation()
        self.locationManager?.startUpdatingLocation()
        self.locationManager?.stopMonitoringSignificantLocationChanges()
    }
    //MARK: -CLLocationManagerProtocol methods

    func startLocationManager(){
        self.locationManager?.delegate = self
        
        let status = CLLocationManager.authorizationStatus()
        
        if(status != CLAuthorizationStatus.Denied && status != CLAuthorizationStatus.NotDetermined){
            self.locationManager?.startUpdatingLocation()
        }
    }
    
    func stopLocationManager(){
        self.locationManager?.stopUpdatingLocation()
    }
    
    func requestAlwaysAuthorization(){
        let status = CLLocationManager.authorizationStatus()
        if (status ==  CLAuthorizationStatus.Denied || status == CLAuthorizationStatus.AuthorizedWhenInUse){
            var title: String!
            if(status == CLAuthorizationStatus.Denied){
                title = "Сервисы геолокации отключены"
                
                let msg = "Включите службу геолокации в настройках"
                
                let alert = UIAlertController(title: title,
                    message: msg,
                    preferredStyle: UIAlertControllerStyle.Alert)
                
                let cancelAction = UIAlertAction(title: "Отмена",
                    style: .Cancel, handler: nil)
                alert.addAction(cancelAction)
                
                let settingsGoAction = UIAlertAction(title: "Настройки", style: .Default, handler: { (action) -> Void in
                    let settingsURL = NSURL(string: UIApplicationOpenSettingsURLString)
                    UIApplication.sharedApplication().openURL(settingsURL!)
                })
                alert.addAction(settingsGoAction)
                
                UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
            }
        } else if(status == CLAuthorizationStatus.NotDetermined){
            self.locationManager?.requestAlwaysAuthorization()
        }
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        requestAlwaysAuthorization()
    }
    
    func getLocation(){
        startLocationManager()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("UPDATED LOCATION")
        let updatedLocation = locations.last
        let sourceStringURL = (APP.i().networkManager?.domain ??  "") + (APP.i().networkManager?.methodsStructure?.getUserLocation() ?? "")
        let myQueue = dispatch_queue_create("backgroundqueue", nil)
        
        if let user = APP.i().user{
            if let userId = APP.i().user?.userId{
                
                var gender = "notdefined"
                if let g = APP.i().user?.gender{
                    if(g == .Female){
                        gender = "woman"
                    } else if(g == .Male){
                        gender = "man"
                    }
                }
                let parametersDict = ["user_id":"\(userId)", "lat":"\(updatedLocation?.coordinate.latitude ?? 0)",  "lon":"\(updatedLocation?.coordinate.longitude ?? 0)", "type":"\(APP.i().user?.auth ?? "")", "sex":gender]
                print(parametersDict)
                
                requestData(.POST, sourceStringURL, parameters: parametersDict, encoding: .URL, headers: nil)
                    .observeOn(ConcurrentDispatchQueueScheduler(queue: myQueue))
                    .debug()
                    .subscribe(onNext: { (response, data) -> Void in
                        print(JSON(data: data))
                            
                    }).addDisposableTo(self.disposeBag)
            }
        }

    }
    
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        print(newLocation)
    }
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        
    }
    
}