//
//  ProfileViewController.swift
//  PulsePolis
//
//  Created by IMAC  on 22.11.15.
//  Copyright © 2015 IMAC . All rights reserved.
//

import UIKit


class ProfileViewController: UIViewController {
    
    @IBOutlet var ageLabel: UILabel!
    @IBOutlet var avatarXConstraint: NSLayoutConstraint!
    @IBOutlet var avatar: UIImageView!
    var avatarURL: String?
    @IBOutlet var nameLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        if let photoUrl = APP.i().user?.photoURL{
            if let url = NSURL(string: photoUrl){
                if let data = NSData(contentsOfURL: url){
                    avatar.image = UIImage(data: data)
                }
            }
        }
        createMaskForImage(avatar)
        // Do any additional setup after loading the view.
        self.ageLabel.hidden = true
        nameLabel.text = (APP.i().user?.firstName ?? "") + " " + (APP.i().user?.lastName ?? "")
        ageLabel.text = "\(APP.i().user?.age)"
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
    
    
    @IBAction func btnPressed(sender: AnyObject) {
        switch(sender.tag){
        case 0:
            APP.i().showCenterPanel()
            break
        case 1:
            self.navigationController?.popViewControllerAnimated(true)
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
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
