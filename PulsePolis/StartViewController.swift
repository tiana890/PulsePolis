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
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if(APP.i().user?.gender == .Female){
            femaleSelected()
        } else if(APP.i().user?.gender == .Male){
            maleSelected()
        }
        
        avatar.image = UIImage(named: "ava_big")
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
        
        if(ifStart){
            self.startBtn.hidden = false
            self.saveBtn.hidden = true
        } else {
            self.startBtn.hidden = true
            self.saveBtn.hidden = false
        }
    }
    
    @IBAction func selectCity(sender: AnyObject) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let pickerViewController = storyboard.instantiateViewControllerWithIdentifier("pickerControllerID")
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
}
