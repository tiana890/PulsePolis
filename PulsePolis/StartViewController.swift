//
//  StartViewController.swift
//  PulsePolis
//
//  Created by IMAC  on 25.11.15.
//  Copyright © 2015 IMAC . All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import RxBlocking

import RxAlamofire

import SwiftyJSON

class StartViewController: BaseViewController {
    
    @IBOutlet var maleText: UILabel!
    @IBOutlet var femaleText: UILabel!
    @IBOutlet var maleBtn: UIButton!
    @IBOutlet var femaleBtn: UIButton!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var avatar: UIImageView!
    
    @IBOutlet var cityLabel: UILabel!
    @IBOutlet var locationLabel: UILabel!
    
    @IBOutlet var startBtn: UIButton!
    
    @IBOutlet var indicator: UIActivityIndicatorView!
    @IBOutlet var defineCityLabel: UILabel!
    
    var subscription: Disposable?
    
    let selectedColor = ColorHelper.defaultColor
    let color = UIColor(red: 150.0/255.0, green: 153.0/255.0, blue: 157.0/255.0, alpha: 1.0)
    
    let sourceStringURL = "http://hotfinder.ru/hotjson/cities.php"
    let postLocationCoordinates = "http://hotfinder.ru/hotjson/definecity.php"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        APP.i().locationManager?.startLocationManager()
        
        var u = APP.i().user
        print(APP.i().user?.photoURL)
        
        avatar.image = UIImage(data: NSData(contentsOfURL: NSURL(string: APP.i().user!.photoURL!)!)!)
        createMaskForImage(avatar)
        
        if(APP.i().user?.gender == .Female){
            femaleSelected()
        } else if(APP.i().user?.gender == .Male){
            maleSelected()
        }
        
        self.nameLabel.text = (APP.i().user?.firstName ?? "") + " " + (APP.i().user?.lastName ?? "")
        self.hideIndicator()

        if (APP.i().city == nil){
            defineCity()
            self.showIndicator()
        }
    }
    
    func showIndicator(){
        indicator.startAnimating()
        cityLabel.hidden = true
        locationLabel.hidden = true
        defineCityLabel.hidden = false
    }
    
    func hideIndicator(){
        indicator.stopAnimating()
        indicator.hidden = true
        cityLabel.hidden = false
        cityLabel.text = APP.i().city?.city ?? "не определено"
        locationLabel.hidden = false
        defineCityLabel.hidden = true
    }
    
    func defineCity(){
        
        let parametersDict:[String: AnyObject] = ["user_id": APP.i().user?.userId ?? "", "lat": APP.i().locationManager?.location?.lat ?? "", "lon": APP.i().locationManager?.location?.lon ?? ""]
        
        self.subscription = requestData(.POST, postLocationCoordinates, parameters: parametersDict, encoding: .URL, headers: nil)
            .observeOn(MainScheduler.instance)
            .debug()
            .subscribe(onNext: { (response, data) -> Void in
                
                let defineCityResponse = DefineCityResponse(json: JSON(data: data))
                print(JSON(data: data))
                if(defineCityResponse.status == "OK"){
                    let city = City()
                    city.id = defineCityResponse.id
                    city.city = defineCityResponse.city
                    APP.i().city = city
                    self.hideIndicator()
                } else {
                    self.showAlert("Ошибка", msg: "Невозможно определить город")
                    self.hideIndicator()
                }
                
                }, onError: { (err) -> Void in
                    self.showAlert("Ошибка", msg: "Произошла ошибка при определении города")
                    self.hideIndicator()
                    
                }, onCompleted: { () -> Void in
                    
                }, onDisposed: { () -> Void in
                    
            })
        
        self.addSubscription(self.subscription!)
        
    }
    
    func femaleSelected(){
        femaleBtn.selected = true
        femaleText.textColor = selectedColor
        
        maleBtn.selected = false
        maleText.textColor = color
    }
    
    func maleSelected(){
        femaleBtn.selected = false
        femaleText.textColor = color
        
        maleBtn.selected = true
        maleText.textColor = selectedColor
    }
    
    @IBAction func femaleBtnPressed(sender: AnyObject) {
        femaleSelected()
        APP.i().user?.gender = Gender.Female
    }
    
    @IBAction func maleBtnPressed(sender: AnyObject) {
        maleSelected()
        APP.i().user?.gender = Gender.Male
        
    }
    
    func createMaskForImage(image: UIImageView){
        let mask = CALayer()
        let maskImage = UIImage(named: "avatar_shape")
        mask.contents = maskImage?.CGImage
        mask.frame = CGRectMake(0, 0,maskImage!.size.width, maskImage!.size.height)
        image.layer.mask = mask
        image.layer.masksToBounds = true
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
