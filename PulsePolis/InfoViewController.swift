//
//  InfoViewController.swift
//  PulsePolis
//
//  Created by IMAC  on 12.03.16.
//  Copyright © 2016 IMAC . All rights reserved.
//

import UIKit

class InfoViewController: UIViewController {

  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = UIImage(named:"shadow_nav")
        self.navigationController?.navigationBar.translucent = true
        self.navigationController?.navigationBar.backgroundColor = UIColor(red: 52.0/255.0, green: 52.0/255.0, blue: 52.0/255.0, alpha: 0.15)
    }
   
    @IBAction func backBtnPressed(sender: AnyObject) {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
}
