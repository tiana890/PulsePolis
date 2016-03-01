//
//  PlaceCellTableViewCell.swift
//  PulsePolis
//
//  Created by IMAC  on 29.11.15.
//  Copyright © 2015 IMAC . All rights reserved.
//

import UIKit
import CoreLocation

class PlaceCellTableViewCell: SWTableViewCell{
    
    @IBOutlet var distance: UILabel!
    @IBOutlet var address: UILabel!
    @IBOutlet var name: UILabel!
    @IBOutlet var female: UIImageView!
    @IBOutlet var male: UIImageView!
    
    @IBOutlet var visitIndex: UILabel!
    
    @IBOutlet var placeType: UILabel!
    
    @IBOutlet var placeTypeImg: UIImageView!
    
    @IBOutlet var indexView: IndexView!
    
    
    @IBOutlet var ruble0: UIImageView!
    @IBOutlet var ruble1: UIImageView!
    @IBOutlet var ruble2: UIImageView!
    @IBOutlet var ruble3: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func configureCell(place: Place){
        
        if let n = place.name{
            self.name.text = n
        }
        
        if let addr = place.address{
            self.address.text = addr
        }
        
        if let index = place.visitIndex{
            self.visitIndex.text = index
            
        }
        
        
        configureIndexView(place)
        
        if let type = place.placeType{
            if(type == "bar"){
                self.placeType.text = "Бар"
                self.placeTypeImg.image = UIImage(named: "bar")
            } else if(type == "restaurant"){
                self.placeType.text = "Ресторан"
                self.placeTypeImg.image = UIImage(named: "restaurant")
            } else if(type == "club"){
                self.placeType.text = "Клуб"
                self.placeTypeImg.image = UIImage(named: "club")
            }
        }
        
        if let lat = place.lat{
            if let lon = place.lon{
                let loc1 = CLLocation(latitude: (lat as NSString).doubleValue, longitude: (lon as NSString).doubleValue)
                let loc2 = CLLocation(latitude: APP.i().locationManager?.location?.lat ?? 0.0, longitude: APP.i().locationManager?.location?.lon ?? 0.0)
                let kmValue = Int(round(loc1.distanceFromLocation(loc2)/1000))
                print(kmValue)
                if(kmValue >= 1){
                    self.distance.text = "\(kmValue) км"
                } else {
                    let newKmValue = Double(round(loc1.distanceFromLocation(loc2)/100)/10)
                    self.distance.text = "\(newKmValue) км"
                }
            }
        }
        
        configureCocktailPrice(place)
    }
    
    func configureIndexView(place: Place){
        
        var col: UIColor?
        if let index = place.visitIndex{
            col = ColorHelper.getColorByIndex(index)
            indexView.color = col
            indexView.femaleIndex = place.woman
            indexView.setNeedsDisplay()
            female.image = self.filledImageFrom(UIImage(named: "woman")!, color: col!)
            male.image = self.filledImageFrom(UIImage(named: "man")!, color: col!)
        }
    }
    
    func configureCocktailPrice(place: Place){
        self.ruble0.image = UIImage(named: "ruble_deselected")
        self.ruble1.image = UIImage(named: "ruble_deselected")
        self.ruble2.image = UIImage(named: "ruble_deselected")
        self.ruble3.image = UIImage(named: "ruble_deselected")
        
        if let cocktailPrice = place.cocktailPrice{
            switch(cocktailPrice){
            case "1":
                self.ruble0.image = UIImage(named: "ruble")
                break
            case "2":
                self.ruble0.image = UIImage(named: "ruble")
                self.ruble1.image = UIImage(named: "ruble")
                break
            case "3":
                self.ruble0.image = UIImage(named: "ruble")
                self.ruble1.image = UIImage(named: "ruble")
                self.ruble2.image = UIImage(named: "ruble")
                break
            case "4":
                self.ruble0.image = UIImage(named: "ruble")
                self.ruble1.image = UIImage(named: "ruble")
                self.ruble2.image = UIImage(named: "ruble")
                self.ruble3.image = UIImage(named: "ruble")
                break
            default:
                break
            }
        }
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
