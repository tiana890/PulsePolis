//
//  ProfileViewController.swift
//  PulsePolis
//
//  Created by IMAC  on 22.11.15.
//  Copyright © 2015 IMAC . All rights reserved.
//

import UIKit
import ReachabilitySwift


class ProfileViewController: UIViewController {
    
    enum ButtonType: Int{
        case Map
        case Profile
        case Feedback
        case Exit
    }
    
    let FEEDBACK_SEGUE = "feedbackSegue"
    
    @IBOutlet var ageLabel: UILabel!
    @IBOutlet var avatarXConstraint: NSLayoutConstraint!
    @IBOutlet var avatar: UIImageView!
    var avatarURL: String?
    @IBOutlet var nameLabel: UILabel!
    
    @IBOutlet var constraint: NSLayoutConstraint!
    var reachability: Reachability?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let screenSize = UIScreen.mainScreen().bounds.size
        if(screenSize.height == 480.0){
            self.constraint.constant = 85.0
            
        }
        
        // Do any additional setup after loading the view.
        self.ageLabel.hidden = true
        nameLabel.text = (APP.i().user?.firstName ?? "") /*+ " " + (APP.i().user?.lastName ?? "")*/
        ageLabel.text = "\(APP.i().user?.age)"
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        avatar.image = UIImage(named: "ava_big")
        if let photoUrl = APP.i().user?.photoURL{
            if let url = NSURL(string: photoUrl){
                if let data = NSData(contentsOfURL: url){
                    avatar.image = UIImage(data: data)
                }
            }
        }
        createMaskForImage(avatar)
        
        setReachability()
        
    }
    
    func setReachability(){
        do {
            reachability = try Reachability.reachabilityForInternetConnection()
        } catch {
            print("ERROR: Unable to create Reachability")
            return
        }
        
        reachability!.whenReachable = { reachability in
            dispatch_async(dispatch_get_main_queue()) {
                self.avatar.image = UIImage(named: "ava_big")
                if let photoUrl = APP.i().user?.photoURL{
                    if let url = NSURL(string: photoUrl){
                        if let data = NSData(contentsOfURL: url){
                            self.avatar.image = UIImage(data: data)
                        }
                    }
                }
                self.createMaskForImage(self.avatar)
            }
        }
        
        do {
            try reachability!.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
        
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createMaskForImage(image: UIImageView){
        let mask = CALayer()
        let maskImage = UIImage(named: "avatar_shape")
        mask.contents = maskImage?.CGImage
        mask.frame = CGRectMake(0, 0,maskImage!.size.width, maskImage!.size.height)
        image.layer.mask = mask
        image.layer.masksToBounds = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        
        self.reachability?.stopNotifier()
    }
    
    @IBAction func btnPressed(sender: AnyObject) {
        switch(sender.tag){
        case ButtonType.Map.rawValue:
            APP.i().showCenterPanel()
            break
        case ButtonType.Profile.rawValue:
            if let childControllers = self.navigationController?.childViewControllers{
                for(chVC) in childControllers{
                    if(chVC.classForCoder == StartViewController.classForCoder()){
                        (chVC as! StartViewController).ifStart = false
                    }
                    
                }
            }
            self.navigationController?.popViewControllerAnimated(true)
            break
        case ButtonType.Feedback.rawValue:
            self.navigationController?.popViewControllerAnimated(true)
            break
        case ButtonType.Exit.rawValue:
            let alert = UIAlertController(title: title,
                message: "Вы действительно хотите выйти?",
                preferredStyle: UIAlertControllerStyle.Alert)
            
            
            let action = UIAlertAction(title: "OK",
                style: .Default, handler: { (action) -> Void in
                if let mainNavigationController = self.navigationController as? MainNavigationController{
                    mainNavigationController.exit()
                }
            })
            let cancelAction = UIAlertAction(title: "Oтмена",
                style: .Default, handler: nil)

            alert.addAction(action)
            alert.addAction(cancelAction)
            self.presentViewController(alert, animated: true, completion: nil)
            
            break
        default:
            break
        }
        
    }
    
    /*
    -(void)createMaskForImage:(UIImageView *)image
    {
    CALayer *mask = [CALayer layer];
    UIImage *maskImage = [UIImage imageNamed:@"circle.png"];
    mask.contents = (id)[maskImage CGImage];
    mask.frame = CGRectMake(0, 0,maskImage.size.width, maskImage.size.height);
    image.layer.mask = mask;
    image.layer.masksToBounds = YES;
    }
    */
    
        // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == FEEDBACK_SEGUE){
            APP.i().mainViewController?.fromAvatar = true
        }
    }
    
    
}
