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

class AuthorizationViewController: UIViewController, VKSdkDelegate {
    let START_SEGUE_IDENTIFIER = "startSegue"

    //MARK: -IBOutlets
    @IBOutlet var vkBtn: UIButton!
    @IBOutlet var facebookBtn: UIButton!
    @IBOutlet var indicator: UIActivityIndicatorView!
    
    @IBOutlet var facebookImageView: UIImageView!
    @IBOutlet var vkImageView: UIImageView!
    
    @IBOutlet var facebookLabel: UILabel!
    @IBOutlet var vkLabel: UILabel!
    
    var url: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        /*
        var vksdkInstance = VKSdk.initializeWithAppId("5144665")
        vksdkInstance.registerDelegate(self)
    
        VKSdk.wakeUpSession(nil) { (state, error) -> Void in
            if(state == VKAuthorizationState.Authorized){
                print("OK")
            } else if(error != nil) {
                print("error")
            } 
        }*/
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
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
                    let fbGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "bio, first_name, gender, picture.width(180).height(180), age_range"])
                  
                    fbGraphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
                        if(error == nil){
                            
                            print(result)
                            var user = User()
                            if let res = result as? NSDictionary{
                                if let firstName = res.valueForKey("first_name") as? String{
                                    user.name = firstName
                                }
                                if let gender = res.valueForKey("gender") as? String{
                                    if(gender == "female"){
                                        user.gender = 1
                                    } else if(gender == "man"){
                                        user.gender = 2
                                    }
                                }
                                if let picture = res.valueForKey("picture") as? NSDictionary{
                                    if let data = picture.valueForKey("data") as? NSDictionary{
                                        if let u = data.valueForKey("url") as? NSString{
                                            self.url = u as String
                                            user.small_photo = UIImage(data: NSData(contentsOfURL: NSURL(string: self.url!)!)!)
                                            user.photo = user.small_photo
                                            user.photoURL = self.url
                                            APP.i().user = user
                                            self.hideActivityIndicator()
                                            self.performSegueWithIdentifier(self.START_SEGUE_IDENTIFIER, sender: self)
                                        }
                                    }
                                }
                            }
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
        var vksdkInstance = VKSdk.initializeWithAppId("5144665")
        vksdkInstance.registerDelegate(self)
        VKSdk.authorize([VK_PER_PHOTOS], withOptions: VKAuthorizationOptions.UnlimitedToken)
        
    }
    
    func vkSdkAccessAuthorizationFinishedWithResult(result: VKAuthorizationResult!) {
        print(result)
        VKSdk.wakeUpSession([VK_PER_PHOTOS]) { (state, error) -> Void in
            if(state == VKAuthorizationState.Authorized){
                print("OK")
                var user = User()
                user.vkID = VKSdk.accessToken().userId
                let request = VKApi.users().get([VK_API_FIELDS:"id, first_name, bdate, sex, photo_200"])
                request.executeWithResultBlock({ (response) -> Void in
                    
                    if let array = response.json as? NSArray{
                        print(array)
                        if let dict = array[0] as? NSDictionary{
                            if let bdate = dict["bdate"] as? String{
                            }
                            if let sex = dict["sex"] as? NSNumber{
                                user.gender = sex.integerValue
                            }
                            if let name = dict["first_name"] as? String{
                                user.name = name
                            }
                            if let photoURL = dict["photo_200"] as? String{
                                user.photo = UIImage(data: NSData(contentsOfURL: NSURL(string: photoURL)!)!)
                                user.photoURL = photoURL as String
                            }
                            print(user)
                        }
                    }
                    APP.i().user = user
                    self.hideActivityIndicator()
                    self.performSegueWithIdentifier(self.START_SEGUE_IDENTIFIER, sender: self)
                    
                    }, errorBlock: { (error) -> Void in
                    print("error")
                })
                
                
            } else if(error != nil) {
                print("error")
            }
        }
        self.hideActivityIndicator()
    }
    
    func vkSdkUserAuthorizationFailed() {
        self.hideActivityIndicator()
    }
    
    func vkSdkAccessTokenUpdated(newToken: VKAccessToken!, oldToken: VKAccessToken!) {
        self.hideActivityIndicator()
    }
    
    func vkSdkTokenHasExpired(expiredToken: VKAccessToken!) {
        self.hideActivityIndicator()
    }
    
    //MARK: -Segues
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == START_SEGUE_IDENTIFIER){
            if let destController = segue.destinationViewController as? StartViewController{
                destController.avatarURL = self.url
            }
        }
    }
}
