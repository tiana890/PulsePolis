//
//  InfoViewController.swift
//  PulsePolis
//
//  Created by IMAC  on 12.03.16.
//  Copyright © 2016 IMAC . All rights reserved.
//

import UIKit

class InfoViewController: UIViewController {

    @IBOutlet var txtView: UITextView!
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var attributedText = self.txtView.attributedText
        var mutableAttrText = NSMutableAttributedString(attributedString: attributedText)
        mutableAttrText.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor(), range: NSMakeRange(0, attributedText.length))
        
        self.txtView.attributedText = mutableAttrText
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = UIImage(named:"shadow_nav")
        self.navigationController?.navigationBar.translucent = true
        self.navigationController?.navigationBar.backgroundColor = UIColor(red: 52.0/255.0, green: 52.0/255.0, blue: 52.0/255.0, alpha: 0.15)
    }
    
    
   
    @IBAction func backBtnPressed(sender: AnyObject) {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
}
