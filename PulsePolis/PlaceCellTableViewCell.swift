//
//  PlaceCellTableViewCell.swift
//  PulsePolis
//
//  Created by IMAC  on 29.11.15.
//  Copyright © 2015 IMAC . All rights reserved.
//

import UIKit


class PlaceCellTableViewCell: SWTableViewCell{

    @IBOutlet var female: UIImageView!
    @IBOutlet var male: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        let color = UIColor(red: 255/255, green: 47/255, blue: 91/255, alpha: 1.0)
        // Initialization code
        female.image = self.filledImageFrom(UIImage(named: "woman")!, color: color)
        //female.image = UIImage(named: "woman")!
        male.image = self.filledImageFrom(UIImage(named: "man")!, color: color)
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
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
