
//  PickerViewController.swift
//  PulsePolis
//
//  Created by IMAC  on 06.02.16.
//  Copyright © 2016 IMAC . All rights reserved.
//

import UIKit
import RxSwift
import RxAlamofire
import SwiftyJSON

class PickerViewController: BaseViewController, UIPickerViewDataSource, UIPickerViewDelegate{
    
    @IBOutlet var picker: UIPickerView!
    @IBOutlet var datePicker: UIDatePicker!
    
    @IBOutlet var navBar: UINavigationBar!
    var cities: [City]?
    
    var sourceController: UIViewController?
    
    @IBOutlet var titleLabel: UILabel!
    var ifDate = false
    var date: NSDate?
    
    var subscription: Disposable?
    
    
    var newDate: NSDate?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        getCities()
        customizeNavBar()
        if(ifDate){
            self.picker.hidden = true
            self.datePicker.hidden = false
            
            self.titleLabel.text = "Выбор города"
            if let vc = self.sourceController as? MainViewController{
                let time = vc.todayStatisticsManager.statisticsTime
                self.datePicker.setDate(time ?? NSDate(), animated: false)
                self.titleLabel.text = "Выбор времени"
                self.datePicker.setValue(ColorHelper.defaultColor, forKey: "textColor")
                self.datePicker.datePickerMode = UIDatePickerMode.Time
            }
        }

    }
    
    func customizeNavBar(){
        self.navBar.setBackgroundImage(UIImage(named:"nav_background"), forBarMetrics: UIBarMetrics.Default)
        self.navBar.translucent = true
        self.navBar.shadowImage = UIImage(named:"shadow_nav")
        self.navBar.barTintColor = UIColor.clearColor()
        self.navBar.barStyle = .Default
        self.navBar.backgroundColor = UIColor.clearColor()

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
            }
    
    func getCities(){
        
        self.cities = APP.i().cities
        
        for(var i = 0; i < self.cities?.count; i++){
            if(APP.i().city?.id! == self.cities![i].id!){
                self.picker.selectRow(i, inComponent: 0, animated: false)
            }
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        if(self.ifDate){
            if let vc = self.sourceController as? MainViewController{
                if let nDate = self.newDate{
                    vc.todayStatisticsManager.statisticsTime = nDate
                    print(vc.todayStatisticsManager.statisticsTime)
                    print(vc.todayStatisticsManager.statisticsTimeString)
                }

            }
        }
        
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return cities?.count ?? 0
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print(self.cities![row])
        APP.i().city = self.cities![row]
    }
    
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    @IBAction func backBtnPressed(sender: AnyObject) {
        if let _ =
            self.navigationController?.popToRootViewControllerAnimated(true){
                //                APP.i().city = self.cities![self.picker.selectedRowInComponent(0)]
                
        } else {
            //            APP.i().city = self.cities![self.picker.selectedRowInComponent(0)]
            self.dismissViewControllerAnimated(true, completion: { () -> Void in
                
            })
        }
    }
    
    
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let string = self.cities![row].city
        return NSAttributedString(string: string!, attributes: [NSForegroundColorAttributeName:ColorHelper.defaultColor])
    }
    
    @IBAction func datePickerValueChanged(sender: UIDatePicker) {
        self.newDate = sender.date
    }
    
}
