//
//  SettingsViewController.swift
//  PulsePolis
//
//  Created by IMAC  on 06.12.15.
//  Copyright © 2015 IMAC . All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet var slider1: UISlider!
    @IBOutlet var slider2: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        slider1.setThumbImage(UIImage(named: "slider_thumb"), forState: UIControlState.Normal)
       // slider2.setThumbImage(UIImage(named: "slider_thumb"), forState: UIControlState.Normal)
        
        /*
        slider1.setMaximumTrackImage(UIImage(named: "slider_track_1"), forState: UIControlState.Normal)
        slider1.setMinimumTrackImage(UIImage(named: "slider_track_1"), forState: UIControlState.Normal)
        
        slider2.setMaximumTrackImage(UIImage(named: "slider_track_2"), forState: UIControlState.Normal)
        slider2.setMinimumTrackImage(UIImage(named: "slider_track_2"), forState: UIControlState.Normal)
        */
        
        // Do any additional setup after loading the view.
    }

    @IBAction func backBtnPressed(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
