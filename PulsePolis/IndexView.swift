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
    
    var ifAnimate = false
    var color: UIColor?
    var femaleIndex: Int?
    
    var shapeView1:CAShapeLayer?
    var shapeView:CAShapeLayer?
    
    var visitIndexLabel: UILabel!
    var visitIndex: String?
    
    override func drawRect(rect: CGRect) {
        redrawLayers()
        
        if(self.visitIndexLabel == nil){
            self.visitIndexLabel = UILabel(frame: CGRect(x: 5.0, y: 15.0, width: 40.0, height: 21.0))
        }
        self.visitIndexLabel.textColor = UIColor.whiteColor()
        self.visitIndexLabel.backgroundColor = UIColor.clearColor()
        let font = UIFont(name: "HelveticaNeue-Thin", size: 24.0)!
        self.visitIndexLabel.textAlignment = .Center
        self.visitIndexLabel.font = font
        self.visitIndexLabel.text = self.visitIndex ?? ""
        self.visitIndexLabel.tag = 1234
        self.addSubview(self.visitIndexLabel)
        
        var mainColor = UIColor(red: 255/255, green: 47/255, blue: 91/255, alpha: 1.0)
        if let col = color{
            mainColor = col
        }
       
        let radius:CGFloat = rect.size.width/2
        
        let circle1 = UIBezierPath(arcCenter: CGPointMake(rect.size.width/2, rect.size.width/2 ) , radius: radius, startAngle: 6*3.14/10/*5*3.14/8*/, endAngle: 4*3.14/10/*3.14/2-3.14/8*/, clockwise: true).CGPath
        
        shapeView1 = CAShapeLayer()
        shapeView1!.path = circle1
        shapeView1!.fillColor = UIColor.whiteColor().CGColor
        shapeView1!.strokeColor = mainColor.colorWithAlphaComponent(0.3).CGColor
        
        shapeView1!.lineWidth = 4.0
        shapeView1!.strokeEnd = 100/100
        shapeView1!.fillColor = UIColor.clearColor().CGColor
        shapeView1!.lineCap = kCALineCapRound
        shapeView1!.rasterizationScale = 2.0 * UIScreen.mainScreen().scale
        shapeView1!.shouldRasterize = true
        self.layer.addSublayer(shapeView1!)
        
        
        let circle = UIBezierPath(arcCenter: CGPointMake(rect.size.width/2, rect.size.width/2) , radius: radius, startAngle: 6*3.14/10/*5*3.14/8*/, endAngle: 4*3.14/10/*3.14/2-3.14/8*/ , clockwise: true).CGPath
        
        shapeView = CAShapeLayer()
        shapeView!.path = circle
        shapeView!.fillColor = UIColor.clearColor().CGColor
        shapeView!.strokeColor = mainColor.CGColor
        shapeView!.lineWidth = 4.0
        if let womanIndex = femaleIndex{
            shapeView!.strokeEnd = 0/*CGFloat(womanIndex)*10.0/100.0*/
        } else {
            shapeView!.strokeEnd = 0
        }
        shapeView!.lineCap = kCALineCapRound
        shapeView!.rasterizationScale = 2.0 * UIScreen.mainScreen().scale
        shapeView!.shouldRasterize = true
        self.layer.addSublayer(shapeView!)
        
        if(self.ifAnimate){
            animateCircle(CGFloat(femaleIndex!)*10.0/100.0)
        } else {
            if let womanIndex = femaleIndex{
                shapeView!.strokeEnd = CGFloat(womanIndex)*10.0/100.0
            }
        }
    }
    
    
    
    func animateCircle(strokeEnd: CGFloat) {
        // We want to animate the strokeEnd property of the circleLayer
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        
        // Set the animation duration appropriately
        animation.duration = 5
        
        // Animate from 0 (no circle) to 1 (full circle)
        animation.fromValue = 0
        animation.toValue = strokeEnd
        
        // Do a linear animation (i.e. the speed of the animation stays the same)
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        
        // Set the circleLayer's strokeEnd property to 1.0 now so that it's the
        // right value when the animation ends.
        
        // Do the actual animation
        shapeView!.strokeEnd = strokeEnd
        
        // Do the actual animation
        shapeView!.addAnimation(animation, forKey: "animateCircle")
        
//        UIView.transitionWithView(self.visitIndexLabel,
//            duration: 3.0,
//            options: [.CurveEaseInOut, .TransitionCrossDissolve],
//            animations: { () -> Void in
//                self.visitIndexLabel.text = "10"
//            }, completion: nil)
    }

   
    
    func redrawLayers(){
        shapeView?.removeFromSuperlayer()
        shapeView1?.removeFromSuperlayer()
        //self.viewWithTag(1234)?.removeFromSuperview()
    }
    
}
