//
//  ViewController.swift
//  PulsePolis
//
//  Created by IMAC  on 10.11.15.
//  Copyright © 2015 IMAC . All rights reserved.
//

import UIKit
import Mapbox
import QuartzCore
import CoreGraphics

class ViewController: UIViewController {

    @IBOutlet var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.imageView.image = self.filledImageFrom(UIImage(named:"man")!, color: UIColor.redColor())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
        
    }
    func filledImageFrom(source: UIImage, color: UIColor) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(source.size, false, UIScreen.mainScreen().scale)
        
        let context = UIGraphicsGetCurrentContext()
        color.setFill()
        
        CGContextTranslateCTM(context, 0, source.size.height)
        CGContextScaleCTM(context, 1.0, -1.0)
        
        CGContextSetBlendMode(context, CGBlendMode.ColorBurn)
        let rect = CGRectMake(0, 0, source.size.width, source.size.height)
        CGContextDrawImage(context, rect, source.CGImage)
        
        CGContextSetBlendMode(context, CGBlendMode.SourceIn)
        CGContextAddRect(context, rect)
        CGContextDrawPath(context,  CGPathDrawingMode.Fill)
        
        var colouredImg = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return colouredImg
        }
}

