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
import AlamofireImage
import SwiftyJSON

import VK_ios_sdk
import FBSDKLoginKit

class StartViewController: BaseViewController {
    
    let INFO_CONTROLLER_STORYBOARD_ID = "infoViewControllerID"
    let SAVE_SEGUE = "saveSegue"
    
    @IBOutlet var maleText: UILabel!
    @IBOutlet var femaleText: UILabel!
    @IBOutlet var maleBtn: UIButton!
    @IBOutlet var femaleBtn: UIButton!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var avatar: UIImageView!
    
    @IBOutlet var cityLabel: UILabel!
    @IBOutlet var locationLabel: UILabel!
    
    @IBOutlet var startBtn: UIButton!
    @IBOutlet var saveBtn: UIButton!
    
    @IBOutlet var indicator: UIActivityIndicatorView!
    @IBOutlet var defineCityLabel: UILabel!
    
    var subscription: Disposable?
    
    let selectedColor = ColorHelper.defaultColor
    let color = UIColor(red: 150.0/255.0, green: 153.0/255.0, blue: 157.0/255.0, alpha: 1.0)
    
    
    var ifStart = true
    
    var ifFromSelectCity = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        APP.i().locationManager?.startLocationManager()
        if(!self.ifFromSelectCity){
            
            avatar.image = UIImage(named: "ava_big")
            createMaskForImage(avatar)
            self.nameLabel.text = ""
            
            if(ifStart){
                self.startBtn.hidden = false
                self.saveBtn.hidden = true
                setGender(true)
                updateUI()
            } else {
                let indicator = UIActivityIndicatorView(activityIndicatorStyle: .White)
                indicator.center = CGPoint(x: self.view.frame.width/2, y: self.avatar.center.y)
                indicator.tag = 123456
                indicator.startAnimating()
                self.view.addSubview(indicator)
                
                self.startBtn.hidden = true
                self.saveBtn.hidden = false
                setGender(false)
                if let type = APP.i().user?.authorizeType{
                    if(type == AuthorizeType.VK){
                        setInfoFromVK()
                    } else if(type == AuthorizeType.Facebook){
                        setInfoFromFacebook()
                    }
                }
            }
            
            if (APP.i().city == nil){
                self.showIndicator()
                APP.i().defineCity({ () -> Void in
                    dispatch_async(dispatch_get_main_queue()) { () -> Void in
                        self.hideIndicator()
                        self.cityLabel.text = APP.i().city?.city ?? "не определено"
                    }
                })
            } else {
                self.hideIndicator()
                self.cityLabel.text = APP.i().city?.city ?? "не определено"
            }
        } else {
            self.ifFromSelectCity = true
            self.cityLabel.text = APP.i().city?.city ?? "не определено"
        }
        
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        APP.i().locationManager?.stopLocationManager()
    }
    
    func updateUI(){
        avatar.image = UIImage(named: "ava_big")
        self.view.viewWithTag(123456)?.removeFromSuperview()
        createMaskForImage(avatar)
        if let photoUrl = APP.i().user?.photoURL{
            if let url = NSURL(string: photoUrl){
                if let data = NSData(contentsOfURL:url){
                    avatar.image = UIImage(data: data)
                    createMaskForImage(avatar)
                }
            }
        }
        self.nameLabel.text = (APP.i().user?.firstName ?? "")

    }
    
    func setInfoFromVK(){
        VKSdk.wakeUpSession([VK_PER_PHOTOS]) { (state, error) -> Void in
            if(error != nil) {
                self.showAlert("Ошибка", msg: "Ошибка входа")
            } else if(state == VKAuthorizationState.Authorized){
                let request = VKApi.users().get([VK_API_FIELDS:"id, first_name, bdate, sex, photo_200, age"])
                request.executeWithResultBlock({ (response) -> Void in
                    print(JSON(response.json))
                    let user = User(jsonFromVK: JSON(response.json))
                    APP.i().user?.firstName = user.firstName
                    APP.i().user?.photoURL = user.photoURL
                    APP.i().user?.saveUser()
                    self.updateUI()
                    }, errorBlock: { (error) -> Void in
                    self.updateUI()
                })
            }
        
        }

        
    }
    
    func setInfoFromFacebook(){
        if(FBSDKAccessToken.currentAccessToken() != nil){
            let fbGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "bio, first_name, last_name, gender, picture.width(200).height(200), age_range"])
            
            fbGraphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
                if(error == nil){
                    let user = User(jsonFromFacebook: JSON(result))
                    APP.i().user?.firstName = user.firstName
                    APP.i().user?.photoURL = user.photoURL
                    APP.i().user?.saveUser()
                    self.updateUI()
                } else{
                    print(error.description)
                    self.updateUI()
                }
            })
        }

    }
    
    func setGender(checkServer: Bool){
        if(APP.i().user?.gender == .Female){
            femaleSelected()
        } else if(APP.i().user?.gender == .Male){
            maleSelected()
        } else {
            if(checkServer){
                self.getUserInfo()
            }
        }
    }
    
    func getUserInfo(){
        let networkClient = NetworkClient()
        let queue = dispatch_queue_create("queue",nil)
        
        subscription = networkClient.getUserInfo().observeOn(ConcurrentDispatchQueueScheduler(queue: queue))
        .debug()
        .subscribe(onNext: { (networkResponse) -> Void in
            self.getUserInfoHandler(networkResponse)
            }, onError: { (errType) -> Void in
                print(errType)
            }, onCompleted: { () -> Void in
                
            }, onDisposed: { () -> Void in
                
        })
        self.addSubscription(subscription!)

    }
    
    func getUserInfoHandler(networkResponse: NetworkResponse){
        dispatch_async(dispatch_get_main_queue(), {
            
            if let response = networkResponse as? GetUserInfoResponse{
                print(response.status)
                if(response.status == Status.Success){
                    if let sex = response.sex{
                        if(sex == "woman"){
                            APP.i().user?.gender = Gender.Female
                        } else if(sex == "man"){
                            APP.i().user?.gender = Gender.Male
                        }
                        APP.i().user?.saveUser()
                        self.setGender(false)
                    }
                }
            }
        })
    }
    
    @IBAction func selectCity(sender: AnyObject) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let pickerViewController = storyboard.instantiateViewControllerWithIdentifier("pickerControllerID")
        self.ifFromSelectCity = true
        self.presentViewController(pickerViewController, animated: true, completion: nil)
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
    
    func showAlertWithCloseHandler(title: String, msg: String){
        let alert = UIAlertController(title: title,
            message: msg,
            preferredStyle: UIAlertControllerStyle.Alert)
        
        let cancelAction = UIAlertAction(title: "OK", style: .Cancel) { (alertAction) -> Void in
            self.goToContainerController()
        }
        
        alert.addAction(cancelAction)
        UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func showPolitics(sender: AnyObject) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let pickerViewController = storyboard.instantiateViewControllerWithIdentifier(INFO_CONTROLLER_STORYBOARD_ID)
        self.presentViewController(pickerViewController, animated: true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == SAVE_SEGUE){
            APP.i().user?.saveUser()
        }
    }
    
    @IBAction func startBtnPressed(sender: AnyObject) {
       
        self.sendUserInfo()
        
        
    }
    
    func sendUserInfo(){
        
        self.saveBtn.hidden = true
        self.startBtn.hidden = true
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: .White)
        indicator.center = self.saveBtn.center
        indicator.startAnimating()
        indicator.tag = 13579
        self.view.addSubview(indicator)
        
        let networkClient = NetworkClient()
        let queue = dispatch_queue_create("queue",nil)
        
        subscription = networkClient.setUserInfo().observeOn(ConcurrentDispatchQueueScheduler(queue: queue))
            .debug()
            .subscribe(onNext: { (networkResponse) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    self.view.viewWithTag(13579)?.removeFromSuperview()
                    if(!self.ifStart){
                        self.saveBtn.hidden = false
                    } else {
                        self.startBtn.hidden = false
                    }
                    if(networkResponse.status == Status.Success){
                        self.goToContainerController()
                    } else {
                        self.treatError()
                    }
                })
                }, onError: { (errType) -> Void in
                    dispatch_async(dispatch_get_main_queue(), {
                        self.view.viewWithTag(13579)?.removeFromSuperview()
                        if(!self.ifStart){
                            self.saveBtn.hidden = false
                        } else {
                            self.startBtn.hidden = false
                        }
                        self.treatError()
                    })
                }, onCompleted: { () -> Void in
                   
                }, onDisposed: { () -> Void in
                    
            })
        self.addSubscription(subscription!)
    }
    
    func treatError(){
        
        self.showAlertWithCloseHandler("Ошибка", msg: "Невозможно сохранить данные" ?? "")
    }
    
    func goToContainerController(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("containerVC")
        self.navigationController?.pushViewController(vc, animated: true)

    }
}
