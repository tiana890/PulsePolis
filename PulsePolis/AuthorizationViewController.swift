//
//  AuthorizationViewController.swift
//  PulsePolis
//
//  Created by IMAC  on 12.11.15.
//  Copyright © 2015 IMAC . All rights reserved.
//

import UIKit
import VK_ios_sdk
import FBSDKLoginKit
import SwiftyJSON
import RxAlamofire
import RxSwift
import Alamofire

class AuthorizationViewController: BaseViewController, VKSdkDelegate {
    let START_SEGUE_IDENTIFIER = "startSegue"
    
    let INFO_CONTROLLER_STORYBOARD_ID = "infoViewControllerID"
    
    //MARK: -IBOutlets
    @IBOutlet var vkBtn: UIButton!
    @IBOutlet var facebookBtn: UIButton!
    @IBOutlet var indicator: UIActivityIndicatorView!
    
    @IBOutlet var facebookImageView: UIImageView!
    @IBOutlet var vkImageView: UIImageView!
    
    @IBOutlet var facebookLabel: UILabel!
    @IBOutlet var vkLabel: UILabel!
    
    var url: String?
    
    var disposeBag = DisposeBag()

    
    //MARK: UIViewController methods
    override func viewDidLoad() {
        super.viewDidLoad()
       
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.hideActivityIndicator()
        APP.i().locationManager?.startLocationManager()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: UI methods
    
    func showActivityIndicator(){
        self.indicator.hidden = false
        self.indicator.startAnimating()
        
        setButtonsHidden(true)
    }
    
    func hideActivityIndicator(){
        self.indicator.hidden = true
        self.indicator.stopAnimating()
        
        setButtonsHidden(false)
    }
    
    func setButtonsHidden(ifHidden: Bool){
        self.vkBtn.hidden = ifHidden
        self.facebookBtn.hidden = ifHidden
        
        self.facebookImageView.hidden = ifHidden
        self.vkImageView.hidden = ifHidden
        
        self.facebookLabel.hidden = ifHidden
        self.vkLabel.hidden = ifHidden
    }
    
    //MARK: UI Selectors
    @IBAction func facebookBtnPressed(sender: AnyObject) {
        self.showActivityIndicator()
        
        let login = FBSDKLoginManager()
        login.logInWithReadPermissions(["public_profile"], fromViewController: self) { (result, error) -> Void in
            
            if (error != nil) {
                self.hideActivityIndicator()
                print("Process error")
            } else if (result.isCancelled) {
                self.hideActivityIndicator()
                print("Cancelled")
            } else {
                if(FBSDKAccessToken.currentAccessToken() != nil){
                    let fbGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "bio, first_name, last_name, gender, picture.width(200).height(200), age_range"])
                    
                    fbGraphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
                        if(error == nil){
                            let user = User(jsonFromFacebook: JSON(result))
                            APP.i().user = user
                            self.authRequest(APP.i().user!)
                        } else{
                            self.hideActivityIndicator()
                            print(error.description)
                        }
                    })
                }
            }
        }
    }
    
    
    @IBAction func vkBtnPressed(sender: AnyObject) {
        showActivityIndicator()
        let vksdkInstance = VKSdk.initializeWithAppId("5144665")
        vksdkInstance.registerDelegate(self)
        //VKSdk.authorize([VK_PER_PHOTOS], withOptions: VKAuthorizationOptions.UnlimitedToken)
        if(VKSdk.isLoggedIn()){
            VKSdk.forceLogout()
        }
        VKSdk.authorize([VK_PER_PHOTOS])
    }
    
    func vkSdkAccessAuthorizationFinishedWithResult(result: VKAuthorizationResult!) {
        print(result)
        VKSdk.wakeUpSession([VK_PER_PHOTOS]) { (state, error) -> Void in
            if(error != nil) {
                self.showAlert("Ошибка", msg: "Ошибка входа")
                self.hideActivityIndicator()
            } else if(state == VKAuthorizationState.Authorized){
                let user = User()
                user.vkID = VKSdk.accessToken().userId
                let request = VKApi.users().get([VK_API_FIELDS:"id, first_name, bdate, sex, photo_200, age"])
                request.executeWithResultBlock({ (response) -> Void in
                    print(JSON(response.json))
                    let user = User(jsonFromVK: JSON(response.json))
                    APP.i().user = user
                    self.authRequest(APP.i().user!)
                    
                    }, errorBlock: { (error) -> Void in
                        print(error)
                        self.showAlert("Ошибка", msg: "Ошибка входа")
                        self.hideActivityIndicator()
                })
            }
            self.hideActivityIndicator()
        }
        
    }
    
    
    func authRequest(user: User){
        
        let gender = user.gender ?? Gender.None
        var sex = ""
        switch(gender){
        case .Female:
            sex = "woman"
            break
        case .Male:
            sex = "man"
            break
        default:
            sex = ""
            break
        }
        
//        let parametersDict:[String: AnyObject] = ["type":user.authorizeType?.rawValue ?? "", "id": user.getSocialId() ?? "", "sex":  sex, "photo": user.photoURL ?? "", "name": user.firstName ?? ""]
        
        var nameForAuth = APP.i().user?.firstName ?? ""
        if(nameForAuth.characters.count > 0){
            nameForAuth += " "
        }
        nameForAuth += APP.i().user?.lastName ?? ""
        
        let networkClient = NetworkClient()
        networkClient.authorize(sex, name: nameForAuth).observeOn(MainScheduler.instance)
        .debug()
        .subscribe(onNext: { (networkResponse) -> Void in
            self.authRequestHandler(networkResponse)
            }, onError: { (errorType) -> Void in
                networkClient.updateSettings().observeOn(MainScheduler.instance)
                .debug()
                .subscribeNext({ (networkResponse) -> Void in
                    if(networkResponse.status == Status.Success){
                        networkClient.authorize(sex, name: nameForAuth).observeOn(MainScheduler.instance)
                        .debug()
                        .subscribeNext({ (networkResponse) -> Void in
                            self.authRequestHandler(networkResponse)
                        }).addDisposableTo(self.disposeBag)
                    } else {
                        self.showAlert("Ошибка", msg: "Произошла ошибка во время авторизации")
                        self.hideActivityIndicator()
                    }
                }).addDisposableTo(self.disposeBag)
            }, onCompleted: { () -> Void in
                
            }) { () -> Void in
                
            }.addDisposableTo(self.disposeBag)
    }
        
    
    func authRequestHandler(authResponse: NetworkResponse){
        if let response = authResponse as? AuthorizeResponse{
            if (response.status == Status.Success){
                APP.i().getCities()
                if let token = response.token{
                    APP.i().user?.token = token
                    APP.i().user?.saveUser()
                    self.hideActivityIndicator()
                    self.performSegueWithIdentifier(self.START_SEGUE_IDENTIFIER, sender: self)
                } else {
                    self.showAlert("Ошибка", msg: "Произошла ошибка во время авторизации")
                    self.hideActivityIndicator()
                }
            } else {
                self.showAlert("Ошибка", msg: "Произошла ошибка во время авторизации")
                self.hideActivityIndicator()
            }

        }
    }
    
    func vkSdkUserAuthorizationFailed() {
        self.showAlert("Ошибка", msg: "Невозможно авторизоваться")
        self.hideActivityIndicator()
    }
    
    func vkSdkAccessTokenUpdated(newToken: VKAccessToken!, oldToken: VKAccessToken!) {
        print("newToken")

    }
    
    func vkSdkTokenHasExpired(expiredToken: VKAccessToken!) {
        print("hasExpired")
        self.hideActivityIndicator()
    }
    
    //MARK: -Segues
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == START_SEGUE_IDENTIFIER){
        }
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
    @IBAction func showPolitics(sender: AnyObject) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let pickerViewController = storyboard.instantiateViewControllerWithIdentifier(INFO_CONTROLLER_STORYBOARD_ID)
        self.presentViewController(pickerViewController, animated: true, completion: nil)
    }
}
