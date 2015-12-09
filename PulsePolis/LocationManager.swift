//
//  LocationManager.swift
//  PulsePolis
//
//  Created by IMAC  on 07.12.15.
//  Copyright © 2015 IMAC . All rights reserved.
//

import UIKit
import CoreLocation


class LocationManager: NSObject, CLLocationManagerDelegate {
    var locationManager: CLLocationManager?
    var locationCoordinate: CLLocationCoordinate2D?{
        get{
            return locationManager?.location?.coordinate
        }
    }
//    var delegate: LocationManagerProtocol?
    
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
        //print(locations.last?.description)
//        delegate?.locationManagerGetCoordinates((locationManager?.location?.coordinate.latitude)!, lng: (locationManager?.location?.coordinate.longitude)!)
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        
    }
    
}