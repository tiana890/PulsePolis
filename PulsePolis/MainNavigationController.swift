//
//  MainNavigationController.swift
//  PulsePolis
//
//  Created by IMAC  on 25.11.15.
//  Copyright © 2015 IMAC . All rights reserved.
//

import UIKit

class MainNavigationController: UINavigationController {
    
    let CONTAINER_CONTROLLER_STORYBOARD_ID = "containerVC"
    let AUTHORIZATION_CONTROLLER_STORYBOARD_ID = "authorizationVC"
    
    let START_CONTROLLER_IDENTIFIER = "startViewController"
    let MAIN_CONTROLLER_IDENTIFIER = "mainViewController"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //Авторизован ли пользователь в системе
        if let u = User.getUserFromDefaults(){
            APP.i().user = u
            let svc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(CONTAINER_CONTROLLER_STORYBOARD_ID)
            self.setViewControllers([svc], animated: true)
        } else {
            let avc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(AUTHORIZATION_CONTROLLER_STORYBOARD_ID)
            self.setViewControllers([avc], animated: true)
        }
        
        // Do any additional setup after loading the view.
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
