//
//  TodayStatisticsCell.swift
//  PulsePolis
//
//  Created by IMAC  on 29.11.15.
//  Copyright © 2015 IMAC . All rights reserved.
//

import UIKit


class TodayStatisticsCell: UITableViewCell {
    
    @IBOutlet var todayTimeLabel: UILabel!
    @IBOutlet var todayTimeImg: UIImageView!
    @IBOutlet var todaySegmentedControl: UISegmentedControl!
    
    @IBOutlet var statisticsTimeLabel: UILabel!
    @IBOutlet var statisticsTimeImg: UIImageView!
    @IBOutlet var statisticsSegmentedControl: UISegmentedControl!
    
    @IBOutlet var segmentedControl: UISegmentedControl!
    
    
    enum SegmentedType: Int{
        case Today
        case Statistics
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        UISegmentedControl.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.whiteColor()], forState: UIControlState.Normal)
        UISegmentedControl.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.whiteColor()], forState: UIControlState.Selected)
        segmentedControl.tintColor = UIColor(red: 41/255, green: 116/255, blue: 124/255, alpha: 0.54)
        todaySegmentedControl.tintColor = UIColor.clearColor()
        statisticsSegmentedControl.tintColor = UIColor.clearColor()
        
        todaySegmentedControl.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "HelveticaNeue-Bold", size: 12.0)!, NSForegroundColorAttributeName: ColorHelper.defaultColor], forState: UIControlState.Selected)
        statisticsSegmentedControl.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "HelveticaNeue-Bold", size: 12.0)!, NSForegroundColorAttributeName: ColorHelper.defaultColor], forState: UIControlState.Selected)
        
        todaySegmentedControl.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "HelveticaNeue-Bold", size: 12.0)!, NSForegroundColorAttributeName: UIColor.whiteColor()], forState: UIControlState.Normal)
        statisticsSegmentedControl.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "HelveticaNeue-Bold", size: 12.0)!, NSForegroundColorAttributeName: UIColor.whiteColor()], forState: UIControlState.Normal)
        
        showToday()
        setTodaySegmentedControl()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBAction func typeChanged(sender: UISegmentedControl) {
        print("typeChanged")
        if(sender.selectedSegmentIndex == SegmentedType.Today.rawValue){
            showToday()
        } else {
            showStatistics()
        }
    }
    
    func showToday(){
        statisticsSegmentedControl.hidden = true
        statisticsTimeImg.hidden = true
        statisticsTimeLabel.hidden = true
        
        todaySegmentedControl.hidden = false
        todayTimeImg.hidden = false
        todayTimeLabel.hidden = false
    }
    
    func showStatistics(){
        statisticsSegmentedControl.hidden = false
        statisticsTimeImg.hidden = false
        statisticsTimeLabel.hidden = false
        
        todaySegmentedControl.hidden = true
        todayTimeImg.hidden = true
        todayTimeLabel.hidden = true
    }
    
    func configureCell(manager: TodayStatisticsManager){
        self.segmentedControl.selectedSegmentIndex = manager.segmentIndex
        self.todaySegmentedControl.selectedSegmentIndex = manager.todaySelectedSegmentIndex
        self.statisticsSegmentedControl.selectedSegmentIndex = manager.statisticsSelectedSegmentIndex
        if(segmentedControl.selectedSegmentIndex == SegmentedType.Today.rawValue){
            showToday()
        } else {
            showStatistics()
        }
        self.statisticsTimeLabel.text = manager.statisticsTimeString ?? getTimeString()
    }
    
    func getTimeString() -> String{
        let components = NSCalendar.currentCalendar().components([.Hour, .Minute], fromDate: NSDate())
        let hour = components.hour
        let minute = components.minute
        
        return (minute > 10) ? "\(hour):\(minute)" : "\(hour):0\(minute)"
    }
    
    
    func setTodaySegmentedControl(){
        let dateFormatter = NSDateFormatter()
        //dateFormatter.dateFormat = "Your date Format"
        //let date = dateFormatter.dateFromString(string1)
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        var comp = calendar.components([.Hour, .Minute], fromDate: date)
        var hour = comp.hour
        var minute = comp.minute
        
        if(minute <= 30){
            comp.minute = 30
        } else {
            comp.minute = 0
            comp.hour = hour + 1
            if(comp.hour == 24){
                comp.hour = 0
            }
        }
        var newDate = calendar.dateFromComponents(comp)
        
        self.todaySegmentedControl.removeAllSegments()
        
        /*
        NSDateComponents *components= [[NSDateComponents alloc] init];
        [components setMinute:30];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDate *myNewDate=[calendar dateByAddingComponents:components toDate:[NSDate date] options:0];
        */
        for(var i = 0; i < 5; i++){
            var minute = 0
            var hour = 0
            if(i == 0){
                hour = comp.hour
                minute = comp.minute
            } else {
                let newComponents = NSDateComponents()
                newComponents.minute = 30
                var nDate = calendar.dateByAddingComponents(newComponents, toDate: newDate!, options:.MatchFirst)
                var c = calendar.components([.Hour, .Minute], fromDate: nDate!)
                hour = c.hour
                minute = c.minute
                newDate = nDate
            }
            
            var title = ""
            if(hour < 10){
                title = "0\(hour):"
            } else {
                title = "\(hour):"
            }
            
            if(minute < 10){
                title = title + "0\(minute)"
            } else {
                title = title + "\(minute)"
            }
            
            self.todaySegmentedControl.insertSegmentWithTitle(title, atIndex: i, animated: false)
        }
    }
    
       
}
