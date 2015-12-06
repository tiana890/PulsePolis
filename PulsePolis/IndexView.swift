//
//  IndexView.swift
//  PulsePolis
//
//  Created by IMAC  on 30.11.15.
//  Copyright © 2015 IMAC . All rights reserved.
//

import UIKit
import CoreGraphics
import QuartzCore

class IndexView: UIView {

   
    override func drawRect(rect: CGRect) {
        let mainColor = UIColor(red: 255/255, green: 47/255, blue: 91/255, alpha: 1.0)
        
        let radius:CGFloat = rect.size.width/2
        
        var circle1 = UIBezierPath(arcCenter: CGPointMake(rect.size.width/2 , rect.size.width/2) , radius: radius, startAngle: 5*3.14/8, endAngle: 3.14/2-3.14/8, clockwise: true).CGPath
        
        
        let shapeView1 = CAShapeLayer()
        shapeView1.path = circle1
        shapeView1.fillColor = UIColor.whiteColor().CGColor
        shapeView1.strokeColor = mainColor.colorWithAlphaComponent(0.3).CGColor
        
        shapeView1.lineWidth = 5.0
        shapeView1.strokeEnd = 100/100
        shapeView1.fillColor = UIColor.clearColor().CGColor
        shapeView1.lineCap = kCALineCapRound
        
        self.layer.addSublayer(shapeView1)
        
        
        var circle = UIBezierPath(arcCenter: CGPointMake(rect.size.width/2 , rect.size.width/2) , radius: radius, startAngle: 5*3.14/8, endAngle: 3.14/2-3.14/8 , clockwise: true).CGPath
        
        
        let shapeView = CAShapeLayer()
        shapeView.path = circle
        shapeView.fillColor = UIColor.clearColor().CGColor
        shapeView.strokeColor = mainColor.CGColor
        shapeView.lineWidth = 5.0
        shapeView.strokeEnd = 50/100
        shapeView.lineCap = kCALineCapRound
        self.layer.addSublayer(shapeView)

        
    }
    

}
