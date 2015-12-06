//
//  HitTestView.swift
//  PulsePolis
//
//  Created by IMAC  on 27.11.15.
//  Copyright © 2015 IMAC . All rights reserved.
//

import UIKit
import Mapbox

class HitTestView: UIView {
    var headerView: UIView?
    var mapView: MGLMapView?
    var table: UITableView?
    
    var statisticsButton: UIButton?
    var userLocationButton: UIButton?
    var cell0: UIView?
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
/*
    - (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    
    // Convert the point to the target view's coordinate system.
    // The target view isn't necessarily the immediate subview
    CGPoint pointForTargetView = [self.targetView convertPoint:point fromView:self];
    
    if (CGRectContainsPoint(self.targetView.bounds, pointForTargetView)) {
    
    // The target view may have its view hierarchy,
    // so call its hitTest method to return the right hit-test view
    return [self.targetView hitTest:pointForTargetView withEvent:event];
    }
    
    return [super hitTest:point withEvent:event];
    }
    */
    
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        
        let pointForTargetView = self.convertPoint(point, fromView: self)
//        print("Point = \(pointForTargetView)")
        let headerFrame = self.convertRect((self.headerView?.frame)!, fromView: self.headerView?.superview)
//        print("Header bounds = \(headerFrame)")
        
        let statisticsButtonFrame = self.convertRect((self.statisticsButton?.frame)!, fromView: self.statisticsButton?.superview)
        let userLocationButtonFrame =  self.convertRect((self.userLocationButton?.frame)!, fromView: self.statisticsButton?.superview)
        
//        let cell0Frame = self.convertRect((self.cell0?.frame)!, fromView: self.cell0?.superview)
        //print(cell0Frame)
        if(CGRectContainsPoint(statisticsButtonFrame, pointForTargetView)){
            return statisticsButton
        }
        
        if(CGRectContainsPoint(userLocationButtonFrame, pointForTargetView)){
            return userLocationButton
        }
        /*
        if(CGRectContainsPoint(cell0Frame, pointForTargetView)){
            if let v = cell0?.hitTest(point, withEvent: event){
                return v
            } else {
                return cell0
            }
        }*/
        
        if(CGRectContainsPoint(headerFrame, pointForTargetView)){
            self.table?.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
            return mapView?.hitTest(point, withEvent: event)
        }
        /*
        if let t = table?.hitTest(point, withEvent: event){
            return  t.hitTest(point, withEvent: event)
        }*/
        return super.hitTest(point, withEvent: event)
    }
}
