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
    
    var lastUpdateDate: NSDate?
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
    
    var timer: NSTimer?
    
    override init() {
        super.init()
        if (self.locationManager == nil){
            self.locationManager = CLLocationManager()
        }
        self.locationManager?.delegate = self
        self.locationManager?.requestAlwaysAuthorization()
        
        self.locationManager?.desiredAccuracy = kCLLocationAccuracyHundredMeters
        self.locationManager?.distanceFilter = 500
        self.locationManager?.allowsBackgroundLocationUpdates = true
        self.locationManager?.pausesLocationUpdatesAutomatically = false
        print(self.locationManager?.pausesLocationUpdatesAutomatically)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "inBackground", name: UIApplicationDidEnterBackgroundNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "inForeground", name: UIApplicationDidBecomeActiveNotification, object: nil)
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    func inBackground()
    {
        self.locationManager?.startMonitoringSignificantLocationChanges()
        self.locationManager?.stopUpdatingLocation()
        
        self.timer?.invalidate()
        self.clearDateUpdate()
        print(self.locationManager?.pausesLocationUpdatesAutomatically)
    }
    func inForeground()
    {
        self.locationManager?.stopMonitoringSignificantLocationChanges()
        self.timer?.invalidate()
        self.updateLoc()
        self.timer = NSTimer.scheduledTimerWithTimeInterval(300, target: self, selector: #selector(LocationManager.updateLoc), userInfo: nil, repeats: true)
        print(self.locationManager?.pausesLocationUpdatesAutomatically)
    }
    
    func clearDateUpdateAndUpdateLocation(){
        self.clearDateUpdate()
        self.updateLoc()
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

    func updateLoc(){
        
        self.locationManager?.requestLocation()
        
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        var onceToken : dispatch_once_t = 0
   
        dispatch_once(&onceToken) {
            
            print("BEFORE UPDATE LOCATION")
            
            if(self.getSecondsDiffBetweenCurrentDateAndLast() > 200 || self.getSecondsDiffBetweenCurrentDateAndLast() == 0 && APP.i().user?.token != nil){
                self.saveDateUpdate()
                print("UPDATE LOCATION....")
                self.saveFactualUpdateRecord(locations.last!)
                let updatedLocation = locations.last
                //let sourceStringURL = (APP.i().networkManager?.domain ??  "") + (APP.i().networkManager?.methodsStructure?.getUserLocation() ?? "")
                let sourceStringURL = "http://hotfinder.ru/hotjson/v1.0/userlocation"
                print(sourceStringURL)
                let myQueue = dispatch_queue_create("backgroundqueue", nil)
                
                if let user = APP.i().user{
                    var gender = "notdefined"
                    if let g = APP.i().user?.gender{
                        if(g == .Female){
                            gender = "woman"
                        } else if(g == .Male){
                            gender = "man"
                        }
                    }
                    let parametersDict = ["lat":"\(updatedLocation?.coordinate.latitude ?? 0)",  "lon":"\(updatedLocation?.coordinate.longitude ?? 0)", "type":"\(APP.i().user?.auth ?? "")", "sex":gender, "token": APP.i().user?.token ?? ""]
                    print(parametersDict)
                    
                    requestData(.POST, sourceStringURL, parameters: parametersDict, encoding: .URL, headers: nil)
                        .observeOn(ConcurrentDispatchQueueScheduler(queue: myQueue))
                        .debug()
                        .subscribe(onNext: { (response, data) -> Void in
                            
                            let jsonResponse = JSON(data: data)
                            print(jsonResponse)
                            if let status = jsonResponse["status"].string{
                                if(status == Status.Success.rawValue){
                                    //self.saveDateUpdate()
                                }
                            }
                            
                        }).addDisposableTo(self.disposeBag)
                }
            } else {
                self.savePotentialUpdateRecord(locations.last!)
            }

        }
     }
    
    func saveFactualUpdateRecord(location: CLLocation){
        let def = NSUserDefaults.standardUserDefaults()
        let d = self.toString(NSDate())
        let element = "factual update: " + d + " " + "lat: \(location.coordinate.latitude ?? 0)" + " lon:\(location.coordinate.longitude ?? 0)"
        if let arr = def.objectForKey("locationRecords") as? [String]{
            var newArr = [String]()
            newArr.appendContentsOf(arr)
            newArr.append(element)
            def.setObject(newArr, forKey: "locationRecords")
        } else {
            var newArr = [String]()
           
            newArr.append(element)
            def.setObject(newArr, forKey: "locationRecords")
        }
        def.synchronize()
    }
    
    func savePotentialUpdateRecord(location: CLLocation){
        let def = NSUserDefaults.standardUserDefaults()
        let d = self.toString(NSDate())
        let element = "potential update: " + d + " " + "lat: \(location.coordinate.latitude ?? 0)" + " lon:\(location.coordinate.longitude ?? 0)"
        if let arr = def.objectForKey("locationRecords") as? [String]{
            var newArr = [String]()
            newArr.appendContentsOf(arr)
            newArr.append(element)
            def.setObject(newArr, forKey: "locationRecords")
        } else {
            var newArr = [String]()
            
            newArr.append(element)
            def.setObject(newArr, forKey: "locationRecords")
        }
        def.synchronize()
    }
    
    func getSecondsDiffBetweenCurrentDateAndLast() -> Int64{
        let def = NSUserDefaults.standardUserDefaults()
        if let interval  = def.objectForKey("currentDate") as? String{
            if let value = Double(interval){
                let val = Int64(NSDate().timeIntervalSinceDate(NSDate(timeIntervalSince1970: value)))
                if(val == 0){
                    return Int64(1)
                }
                return val
            } else {
                return 1
            }
        } else {
            return 0
        }
    }
    
    func toString(date: NSDate) -> String
    {
        //Get Short Time String
        let formatter = NSDateFormatter()
        formatter.dateFormat = "dd MMM HH:mm"
        let str = formatter.stringFromDate(date)
        
        //Return Short Time String
        return str
    }
    
    func saveDateUpdate() -> (){
        let def = NSUserDefaults.standardUserDefaults()
        def.setObject("\(NSDate().timeIntervalSince1970)", forKey: "currentDate")
        def.synchronize()
    }
    
    func clearDateUpdate() -> (){
        let def = NSUserDefaults.standardUserDefaults()
        def.setObject("\(NSTimeIntervalSince1970)", forKey: "currentDate")
        def.synchronize()
    }

    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        
    }
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        
    }
    
}