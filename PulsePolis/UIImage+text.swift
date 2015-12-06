//
//  UIImage+text.swift
//  Agentum
//
//  Created by IMAC  on 18.11.15.
//
//

import UIKit


extension UIImage {
    
    /// Append string to NSMutableData
    ///
    /// Rather than littering my code with calls to `dataUsingEncoding` to convert strings to NSData, and then add that data to the NSMutableData, this wraps it in a nice convenient little extension to NSMutableData. This converts using UTF-8.
    ///
    /// :param: string       The string to be added to the `NSMutableData`.
    
    func textToImage(drawText: NSString)->UIImage{
        
        // Setup the font specific variables
        let textColor: UIColor = UIColor.whiteColor()
        let textFont: UIFont = UIFont(name: "Helvetica Neue", size: 12)!
        
        //Setup the image context using the passed image.
        UIGraphicsBeginImageContext(self.size)
        
        //Setups up the font attributes that will be later used to dictate how the text should be drawn
        let textFontAttributes = [
            NSFontAttributeName: textFont,
            NSForegroundColorAttributeName: textColor,
        ]
        
        //Put the image into a rectangle as large as the original image.
        self.drawInRect(CGRectMake(0, 0, self.size.width, self.size.height))
        

        // Creating a point within the space that is as bit as the image.
        let rect: CGRect = CGRectMake(self.size.width/2-3, self.size.height/2-10, 8.0, 21.0)
        
        //Now Draw the text into an image.
        drawText.drawInRect(rect, withAttributes: textFontAttributes)
        
        // Create a new image out of the images we have created
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // End the context now that we have the image we need
        UIGraphicsEndImageContext()
        
       
        //And pass it back up to the caller.
        return newImage
        
    }

}
