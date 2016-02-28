//
//  AvatarCollectionViewController.swift
//  PulsePolis
//
//  Created by IMAC  on 09.12.15.
//  Copyright © 2015 IMAC . All rights reserved.
//

import UIKit
import AlamofireImage
import RxCocoa
import RxSwift
import RxBlocking

class AvatarCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    let CELL_SIZE_WIDTH = 180.0
    
    @IBOutlet var femaleBtn: UIButton!
    @IBOutlet var maleBtn: UIButton!
    
    let defaultColor = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 0.7)
    let selectedColor = UIColor(red: 31.0/255.0, green: 108.0/255.0, blue: 118.0/255.0, alpha: 0.7)
    
    @IBOutlet var name: UILabel!
    @IBOutlet var femaleLabel: UILabel!
    @IBOutlet var maleLabel: UILabel!
    
    @IBOutlet var collection: UICollectionView!
    var place: Place?
    var visitors:[Visitor]?
    
    var selectedIndex: Int?
    
    var maleVisitors:[Visitor]?{
        get{
            return self.visitors?.filter({ (element) -> Bool in
                if(element.sex == "man"){
                    return true
                }
                return false
            })
        }
    }
    
    var femaleVisitors:[Visitor]?{
        get{
            return self.visitors?.filter({ (element) -> Bool in
                if(element.sex == "woman"){
                    return true
                }
                return false
            })
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.hidden = true
        
        self.name.text = place?.name
        
        self.femaleLabel.text = ""
        if let w = self.place?.woman{
            self.femaleLabel.text = "\(w)%"
        }
        self.maleLabel.text = ""
        if let m = self.place?.man{
            self.maleLabel.text = "\(m)%"
        }
    }
    

  
    enum Gender: Int{
        case None
        case Female
        case Male
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = UIImage(named:"shadow_nav")
        self.navigationController?.navigationBar.translucent = true
        self.navigationController?.navigationBar.backgroundColor = UIColor(red: 52.0/255.0, green: 52.0/255.0, blue: 52.0/255.0, alpha: 0.15)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        var insets = self.collection.contentInset
        let value = (self.view.frame.size.width - (self.collection.collectionViewLayout as! UICollectionViewFlowLayout).itemSize.width) * 0.5
        insets.left = value
        insets.right = value
        self.collection.contentInset = insets
        self.collection.decelerationRate = UIScrollViewDecelerationRateFast
        
        if let ind = self.selectedIndex{
           let x = CGFloat(ind) * CGFloat((CELL_SIZE_WIDTH + 35.0))
           self.collection.setContentOffset(CGPoint(x: x - CGFloat(CELL_SIZE_WIDTH/2) + CGFloat(35.0), y: 0), animated: false)
        }
        
    }
    
    //MARK: Collection view
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as? AvatarCollectionViewCell{
            var visitorsArray: [Visitor]?
            
            if(self.femaleBtn.selected && !self.maleBtn.selected){
                visitorsArray = self.femaleVisitors
            } else if(!self.femaleBtn.selected && self.maleBtn.selected){
                visitorsArray = self.maleVisitors
            } else {
                visitorsArray = self.visitors
            }
            
            let visitor = visitorsArray?[indexPath.row]
            cell.avatarImage.image = UIImage()
            if let avatarUrl = visitor?.avatarUrl{
                cell.avatarImage.af_setImageWithURL(NSURL(string: avatarUrl)!)
                createMaskForImage(cell.avatarImage)
            }
            if let checkin = visitor?.checkin{
                if (checkin.characters.count > 18){
                    let str = (checkin as NSString).substringWithRange(NSMakeRange(11, 5)) as String
                    cell.checkin.text = "Чекин в " + str
                } else {
                    cell.checkin.text = ""
                }
            } else {
                cell.checkin.text = ""
            }
            if let name = visitor?.name{
                cell.name.text = name
            }
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(self.femaleBtn.selected && !self.maleBtn.selected){
            return self.femaleVisitors?.count ?? 0
        } else if(!self.femaleBtn.selected && self.maleBtn.selected){
            return self.maleVisitors?.count ?? 0
        }
        print(self.visitors?.count)
        return self.visitors?.count ?? 0
    }
    
    func createMaskForImage(image: UIImageView){
        let mask = CALayer()
        let maskImage = UIImage(named: "avatar_shape_big")
        mask.contents = maskImage?.CGImage
        mask.frame = CGRectMake(0, 0, maskImage!.size.width, maskImage!.size.height)
        image.layer.mask = mask
        image.layer.masksToBounds = true
        
    }
    
    // MARK: - Navigation
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
    }
    
    @IBAction func backBtnPressed(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func genderSelected(sender: AnyObject) {
        if(sender.tag == Gender.Female.rawValue){
            femaleBtn.selected = !femaleBtn.selected
        } else if(sender.tag == Gender.Male.rawValue){
            maleBtn.selected = !maleBtn.selected
        }
        self.collection.reloadData()
    }
}
