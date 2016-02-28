
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
}
