//
//  UIImage+text.swift
//  Agentum
//
//  Created by IMAC  on 18.11.15.
//
//

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
    
    func textToImage(drawText: NSString, selected: Bool)->UIImage{
        
        // Setup the font specific variables
        print("BEFORE SIZE")
        print(self.size)
        let textColor: UIColor = UIColor.whiteColor()
        
        var size = 13.0
        switch(drawText){
        case "0", "1":
            size = 13.0
            break
        case "2", "3":
            size = 14.0
            break
        case "4", "5", "6":
            size = 15.0
            break
        case "7", "8":
            size = 16.0
            break
        case "9", "10":
            size = 17.0
            break
        default:
            break
        }
        
        if(selected){
            size = 17.0
        }
        
        let textFont: UIFont = UIFont(name: "Helvetica Neue", size: CGFloat(size*2 ))!
        
        //Setup the image context using the passed image.
        UIGraphicsBeginImageContext(self.size)
        
        /*
        /// Make a copy of the default paragraph style
        NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        /// Set line break mode
        paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
        /// Set text alignment
        paragraphStyle.alignment = NSTextAlignmentRight;
        
        NSDictionary *attributes = @{ NSFontAttributeName: font,
        NSParagraphStyleAttributeName: paragraphStyle };
        
        [text drawInRect:rect withAttributes:attributes];
        */
        
        var paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = NSLineBreakMode.ByTruncatingTail
        paragraphStyle.alignment = .Center
        
        let textFontAttributes = [
            NSFontAttributeName: textFont,
            NSForegroundColorAttributeName: textColor,
            NSParagraphStyleAttributeName: paragraphStyle
        ]
        
        
        //Put the image into a rectangle as large as the original image.
        self.drawInRect(CGRectMake(0.0, 0.0, self.size.width, self.size.height))
        print(CGRectMake(0.0, 0.0, self.size.width, self.size.height))
        
        
        // Creating a point within the space that is as bit as the image.
        var rect = CGRect()
        if(self.size.width == 33.0){
            rect = CGRectMake(1.0, self.size.height/2 - CGFloat(size) + 1.0, self.size.width, 21.0)
        } else {
            rect = CGRectMake(1.0, self.size.height/2 - CGFloat(size) + 2.0, self.size.width, 21.0)
        }
        
        //Now Draw the text into an image.
        drawText.drawInRect(rect, withAttributes: textFontAttributes)
        
        // Create a new image out of the images we have created
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // End the context now that we have the image we need
        UIGraphicsEndImageContext()
        
        print("AFTER SIZE")
        print(newImage.size)
        //And pass it back up to the caller.
        return newImage
        
    }
    
}
