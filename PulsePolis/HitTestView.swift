//
//  HitTestView.swift
//  PulsePolis
//
//  Created by IMAC  on 27.11.15.
//  Copyright © 2015 IMAC . All rights reserved.
//

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
    
    var collection: UICollectionView?
    
    var arrayOfViews = Array<UIView>()
    
    
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        
        let pointForTargetView = self.convertPoint(point, fromView: self)
        let headerFrame = self.convertRect((self.headerView?.frame) ?? CGRectZero, fromView: self.headerView?.superview)
        
        let statisticsButtonFrame = self.convertRect((self.statisticsButton?.frame) ?? CGRectZero, fromView: self.statisticsButton?.superview)
        
        if(CGRectContainsPoint(statisticsButtonFrame, pointForTargetView)){
            return statisticsButton
        }
        
        let userLocationButtonFrame =  self.convertRect((self.userLocationButton?.frame) ?? CGRectZero, fromView: self.statisticsButton?.superview)
        
        if(CGRectContainsPoint(userLocationButtonFrame, pointForTargetView)){
            return userLocationButton
        }
        
        /*
        let collectionFrame =  self.convertRect((cell0?.frame)!, fromView: cell0?.superview)
        
        if(CGRectContainsPoint(collectionFrame, pointForTargetView)){
        return cell0?.hitTest(point, withEvent: event)
        }*/
        
        for(var i = 0; i < arrayOfViews.count; i++){
            let viewFrame = self.convertRect(self.arrayOfViews[i].frame, fromView: arrayOfViews[i].superview)
            
            if(CGRectContainsPoint(viewFrame, pointForTargetView) && arrayOfViews[i].hidden == false){
                return arrayOfViews[i]
            }
        }
        
        if(CGRectContainsPoint(headerFrame, pointForTargetView)){
            self.table?.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
            return mapView?.hitTest(point, withEvent: event)
        }
        
        return super.hitTest(point, withEvent: event)
    }
}
