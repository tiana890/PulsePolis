
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
    
    var disposeBag = DisposeBag()
    
    var newDate: NSDate?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
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
        } else {
            self.getCities()
        }
        customizeNavBar()
        
    }
    
    func customizeNavBar(){
        self.navBar.setBackgroundImage(UIImage(named:"nav_background"), forBarMetrics: UIBarMetrics.Default)
        self.navBar.translucent = true
        self.navBar.shadowImage = UIImage(named:"shadow_nav")
        self.navBar.barTintColor = UIColor.clearColor()
        self.navBar.barStyle = .Default
        self.navBar.backgroundColor = UIColor.clearColor()

    }
    
    func getCities(){
        self.cities = APP.i().cities
        
        if(self.cities?.count == 0 || self.cities == nil){
            
            self.picker.hidden = true
            let indicator = UIActivityIndicatorView(activityIndicatorStyle: .White)
            indicator.startAnimating()
            indicator.center = self.view.center
            indicator.tag = 12345
            self.view.addSubview(indicator)
            
            self.getCities({ () -> Void in
                dispatch_async(dispatch_get_main_queue()) { () -> Void in
                    self.view.viewWithTag(12345)?.removeFromSuperview()
                    self.picker.hidden = false
                    self.cities = APP.i().cities
                    
                    self.picker.reloadAllComponents()
                    self.picker.reloadInputViews()
                    
                    for(var i = 0; i < self.cities?.count; i++){
                        if let currentCityId = APP.i().city?.id{
                            if(currentCityId == self.cities![i].id!){
                                self.picker.selectRow(i, inComponent: 0, animated: false)
                            }
                        } else {
                            self.picker.selectRow(0, inComponent: 0, animated: false)
                            if let citiesArray = self.cities{
                                APP.i().city = citiesArray[0]
                            }
                        }
                    }
                    
                }
            })
            
        } else {
            for(var i = 0; i < self.cities?.count; i++){
                if let currentCityId = APP.i().city?.id{
                    if(currentCityId == self.cities![i].id!){
                        self.picker.selectRow(i, inComponent: 0, animated: false)
                    }
                } else {
                    self.picker.selectRow(0, inComponent: 0, animated: false)
                    if let citiesArray = self.cities{
                        APP.i().city = citiesArray[0]
                    }
                }
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
        if let citiesArray = self.cities{
            APP.i().city = citiesArray[row]
        }
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
    
    func getCities(handler: () -> Void){
        let networkClient = NetworkClient()
        
        let queue = dispatch_queue_create("initialqueue", nil)
        let concurrentScheduler = ConcurrentDispatchQueueScheduler(queue: queue)
        
        
        networkClient.getCities().observeOn(concurrentScheduler).subscribe(onNext: { (networkResponse) -> Void in
            self.getCitiesHandler(networkResponse)
            handler()
            }, onError: { (errorType) -> Void in
                self.updateSettings(networkClient, block: { () -> Void in
                    handler()
                })
            }, onCompleted: { () -> Void in
                
            }) { () -> Void in
                
            }.addDisposableTo(self.disposeBag)
        
    }
    
    func updateSettings(client: NetworkClient,block: () -> Void){
        let queue = dispatch_queue_create("updatequeue", nil)
        let concurrentScheduler = ConcurrentDispatchQueueScheduler(queue: queue)
        
        client.updateSettings().observeOn(concurrentScheduler).subscribe(onNext: { (response) -> Void in
            if(response.status == Status.Success){
                client.getCities().observeOn(concurrentScheduler).subscribeNext({ (citiesResponse) -> Void in
                    self.getCitiesHandler(citiesResponse)
                    block()
                }).addDisposableTo(self.disposeBag)
            } else {
                dispatch_async(dispatch_get_main_queue(), {
                    self.showAlert("Ошибка", msg: "Данные не могут быть загружены")
                })
            }
            }, onError: { (err) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    self.showAlert("Ошибка", msg: "Данные не могут быть загружены")
                })
                block()
            }, onCompleted: { () -> Void in
                
            }) { () -> Void in
                
            }.addDisposableTo(self.disposeBag)
    }
    
    func getCitiesHandler(citiesResponse:NetworkResponse){
        if let response = citiesResponse as? CitiesResponse{
            if(response.status == Status.Success){
                APP.i().cities = response.cities
            } else {
                dispatch_async(dispatch_get_main_queue(), {
                    self.showAlert("Ошибка", msg: "Данные не могут быть загружены")
                })
                
            }
        }
    }

    //MARK: Alerts
    func showAlert(title: String, msg: String){
        let alert = UIAlertController(title: title,
            message: msg,
            preferredStyle: UIAlertControllerStyle.Alert)
        
        let cancelAction = UIAlertAction(title: "OK",
            style: .Cancel, handler: nil)
        
        alert.addAction(cancelAction)
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
}
