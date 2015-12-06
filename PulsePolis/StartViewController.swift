//
//  StartViewController.swift
//  PulsePolis
//
//  Created by IMAC  on 25.11.15.
//  Copyright © 2015 IMAC . All rights reserved.
//

import UIKit

class StartViewController: UIViewController {
    
    @IBOutlet var maleText: UILabel!
    @IBOutlet var femaleText: UILabel!
    @IBOutlet var maleBtn: UIButton!
    @IBOutlet var femaleBtn: UIButton!
    var avatarURL: String?
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var avatar: UIImageView!
    
    let selectedColor = UIColor(red: 15.0/255.0, green: 211.0/255.0, blue: 219.0/255.0, alpha: 1.0)
    let color = UIColor(red: 150.0/255.0, green: 153.0/255.0, blue: 157.0/255.0, alpha: 1.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //avatar.image = UIImage(data: NSData(contentsOfURL: (NSURL(string: self.avatarURL!))!)!)
        //avatar.image = APP.i().user?.photo
        avatar.image = UIImage(data: NSData(contentsOfURL: NSURL(string: APP.i().user!.photoURL!)!)!)
        createMaskForImage(avatar)

        if(APP.i().user?.gender == 1){
            femaleSelected()
        } else if(APP.i().user?.gender == 2){
            maleSelected()
        }
        
        self.nameLabel.text = APP.i().user?.name
        
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func femaleBtnPressed(sender: AnyObject) {
        femaleSelected()
        APP.i().user?.gender = 1
    }
    
    @IBAction func maleBtnPressed(sender: AnyObject) {
        maleSelected()
        APP.i().user?.gender = 2
    }
    func createMaskForImage(image: UIImageView){
        let mask = CALayer()
        let maskImage = UIImage(named: "avatar_shape")
        mask.contents = maskImage?.CGImage
        mask.frame = CGRectMake(0, 0,maskImage!.size.width, maskImage!.size.height)
        image.layer.mask = mask
        image.layer.masksToBounds = true
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
