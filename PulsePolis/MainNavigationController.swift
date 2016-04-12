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
        
        updateNavigationStack()
       
    }
    
    func updateNavigationStack(){
        //Авторизован ли пользователь в системе
        if let u = User.getUserFromDefaults(){
            if let _ = u.token{
                APP.i().user = u
                let cvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(CONTAINER_CONTROLLER_STORYBOARD_ID)
                let svc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(START_CONTROLLER_IDENTIFIER)
                self.setViewControllers([svc, cvc], animated: true)
            } else {
                let avc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(AUTHORIZATION_CONTROLLER_STORYBOARD_ID)
                
                self.setViewControllers([avc], animated: true)
            }
        } else {
            let avc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(AUTHORIZATION_CONTROLLER_STORYBOARD_ID)
            self.setViewControllers([avc], animated: true)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func exit(){
        if let u = APP.i().user{
            u.deleteUser()
        }
        updateNavigationStack()
        let favManager = FavoritesManager()
        favManager.removeAllFromFavorites()
        APP.i().settingsManager = SettingsManager()
        
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
