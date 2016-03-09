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
import RxAlamofire
import SwiftyJSON

class AvatarCollectionViewController: BaseViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    let CELL_SIZE_WIDTH = 180.0
    
    @IBOutlet var femaleBtn: UIButton!
    @IBOutlet var maleBtn: UIButton!
    
    var visitorsSubscription: Disposable?
    
    let defaultColor = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 0.7)
    let selectedColor = UIColor(red: 31.0/255.0, green: 108.0/255.0, blue: 118.0/255.0, alpha: 0.7)
    
    @IBOutlet var name: UILabel!
//    @IBOutlet var femaleLabel: UILabel!
//    @IBOutlet var maleLabel: UILabel!
    
    var sourceController: MainViewController?
    @IBOutlet var collection: UICollectionView!
    var place: Place?
    var visitors:[Visitor]?
    
    var selectedIndex: Int?
    
    var _viewDidLayoutSubviewsForTheFirstTime = true
    
    var ifLoadVisitors = false
    
    let visitorsSourceUrl = "http://hotfinder.ru/hotjson/v1.0/visitors.php?place_id="
    
    var maleVisitors:[Visitor]?{
        get{
            return self.visitors?.filter({ (element) -> Bool in
                if(element.sex == "man" || element.sex != "woman"){
                    return true
                }
                return false
            })
        }
    }
    
    var femaleVisitors:[Visitor]?{
        get{
            return self.visitors?.filter({ (element) -> Bool in
                if(element.sex == "woman" || element.sex != "man"){
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
        
        if(ifLoadVisitors){
            if let placeId = self.place?.id{
               self.visitors = [Visitor]()
               self.loadVisitors(placeId)
            }
        }
        
//        self.femaleLabel.text = ""
//        if let w = self.place?.woman{
//            self.femaleLabel.text = "\(w)%"
//        }
//        self.maleLabel.text = ""
//        if let m = self.place?.man{
//            self.maleLabel.text = "\(m)%"
//        }
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
        self.navigationController?.navigationBar.backgroundColor = UIColor(red: 52.0/255.0, green: 52.0/255.0, blue: 52.0/255.0, alpha: 0.15)    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.sourceController?.fromAvatar = true
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
        
        if(self._viewDidLayoutSubviewsForTheFirstTime){
            self._viewDidLayoutSubviewsForTheFirstTime = false
            if let ind = self.selectedIndex{
                /*
                // Calling collectionViewContentSize forces the UICollectionViewLayout to actually render the layout
                [self.collectionView.collectionViewLayout collectionViewContentSize];
                // Now you can scroll to your desired indexPath or contentOffset
                [self.collectionView scrollToItemAtIndexPath:yourDesiredIndexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
                */
                self.collection.collectionViewLayout.collectionViewContentSize()
                self.collection.scrollToItemAtIndexPath(NSIndexPath(forItem: ind, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.CenteredHorizontally, animated: false)
//                let x = CGFloat(ind) * CGFloat((self.CELL_SIZE_WIDTH + 35.0))
//                self.collection.setContentOffset(CGPoint(x: x - CGFloat(self.CELL_SIZE_WIDTH/2) + CGFloat(35.0), y: 0), animated: false)
            }
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    func loadVisitors(placeId: String){
        visitorsSubscription = requestJSON(.GET, visitorsSourceUrl+placeId)
            .observeOn(MainScheduler.instance)
            .debug()
            .subscribe(onNext: { (r, json) -> Void in
                let js = JSON(json)
                let status = js["status"]
                if (status == "OK"){
                    self.visitors?.removeAll()
                    if let arrayOfVisitors = js["visitors"].array{
                        for (j) in arrayOfVisitors{
                            let visitor = Visitor(json: j)
                            self.visitors?.append(visitor)
                        }
                    }
                    self.collection.reloadData()
                    
                } else {
                    //ERROR MSG
                }
                
                }, onError: { (e) -> Void in
                    
                    
            })
        addSubscription(visitorsSubscription!)
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
            cell.avatarImage.image = UIImage(named: "ava_big_big")
            if let avatarUrl = visitor?.avatarUrl{
                let filter = AspectScaledToFillSizeFilter(size: CGSizeMake(cell.avatarImage.frame.width, cell.avatarImage.frame.height))
                cell.avatarImage.af_setImageWithURL(NSURL(string: avatarUrl)!, filter: filter)
                createMaskForImage(cell.avatarImage)
//                cell.avatarImage.af_setImageWithURL(NSURL(string: avatarUrl)!)
//                createMaskForImage(cell.avatarImage)
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
