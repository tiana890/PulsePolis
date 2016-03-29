
//  TodayStatisticsManager.swift
//  PulsePolis
//
//  Created by IMAC  on 12.02.16.
//  Copyright © 2016 IMAC . All rights reserved.
//

import UIKit

class TodayStatisticsManager: NSObject {
    var ifTodaySelected = true
    var segmentIndex = 0
    var todaySelectedSegmentIndex = 0{
        didSet{
            self.ifTodaySelected = !self.ifTodaySelected
        }
    }
    var todayValue: String?
    var statisticsSelectedSegmentIndex = 0
    var statisticsTime: NSDate?
    
    var statisticsTimeString: String{
        get{
            let date = self.statisticsTime ?? NSDate()
            return getTimeString(date)
        }
    }
    
    func getTimeString(date: NSDate) -> String{
        let components = NSCalendar.currentCalendar().components([.Hour, .Minute], fromDate: date)
        let hour = components.hour
        let minute = components.minute
        
        return (minute >= 10) ? "\(hour):\(minute)" : "\(hour):0\(minute)"
    }
    
    static func getTitleForTime() -> String{
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
        
        var title = ""
        if(comp.hour < 10){
            title = "0\(comp.hour):"
        } else {
            title = "\(comp.hour):"
        }
        
        if(comp.minute < 10){
            title = title + "0\(comp.minute)"
        } else {
            title = title + "\(comp.minute)"
        }
        return title
        
    }

}
