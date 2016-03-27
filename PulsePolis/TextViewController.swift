//
//  TextViewController.swift
//  PulsePolis
//
//  Created by IMAC  on 22.03.16.
//  Copyright © 2016 IMAC . All rights reserved.
//

import UIKit

class TextViewController: UIViewController {

    @IBOutlet var txtView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.txtView.text = ""
        self.extractLocationRecords()
    }

    func extractLocationRecords(){
        let def = NSUserDefaults.standardUserDefaults()
        if let arr = def.objectForKey("locationRecords") as? [String]{
            
            for(el) in arr{
                self.txtView.text = self.txtView.text + el + "\n"
            }
        }
        
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
