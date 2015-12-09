//
//  MainViewController.swift
//  PulsePolis
//
//  Created by IMAC  on 22.11.15.
//  Copyright © 2015 IMAC . All rights reserved.
//

import UIKit
import Mapbox
import CoreLocation
import CoreGraphics


class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, MGLMapViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
    
    let CELL_IDENTIFIER = "placeCell"
    let AVATAR_CELL_IDENTIFIER = "avatarCell"
    let STATISTICS_CELL_IDENTIFIER = "statisticsCell"
    
    let COLLECTION_CELL_IDENTIFIER = "avatarCollectionViewCell"
    
    var statisticsMode = false{
        didSet{
            let ip = NSIndexPath(forRow: 0, inSection: 0)
            self.table.reloadRowsAtIndexPaths([ip], withRowAnimation: UITableViewRowAnimation.None)
        }
    }
    @IBOutlet var userLocationButton: UIButton!
    @IBOutlet var statisticsButton: UIButton!
    private let tableHeaderHeight: CGFloat = 400.0
    var headerView: UIView!
    @IBOutlet var mapView: MGLMapView!
    
    @IBOutlet var table: UITableView!
    
    var locationManager: LocationManager?
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = LocationManager()
        locationManager?.startLocationManager()
        
         mapView.delegate = self
               let locationCoordinate = CLLocationCoordinate2DMake(
            55.75222, 37.61556)
        
        mapView.setCenterCoordinate(locationCoordinate, zoomLevel: 15, animated: false)
        
        let styleURL = NSURL(string: "mapbox://styles/marinazayceva/cihonrl0x00efawkrwp4tgd9y")
        mapView.styleURL = styleURL
        
        var point = MGLPointAnnotation()
        point.coordinate = locationCoordinate
        point.title = "Annotation"
        self.mapView.addAnnotation(point)
       
        mapView.userInteractionEnabled = true
        
        if let hitTestView = self.view as? HitTestView{
            hitTestView.mapView = self.mapView
            hitTestView.headerView = self.table.tableHeaderView
            hitTestView.table = self.table
            
            hitTestView.statisticsButton = self.statisticsButton
            hitTestView.userLocationButton = self.userLocationButton
        }
        
        var insets = table.contentInset
        insets.bottom = 44
        table.contentInset = insets
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named:"nav_background"), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = UIImage(named:"shadow_nav")
        self.navigationController?.navigationBar.translucent = true
        self.navigationController?.view.backgroundColor = UIColor.clearColor()
        
        print(self.table.frame)
    }
    
    func setMap(){
        var point = MGLPointAnnotation()
        point.coordinate = (mapView.userLocation?.coordinate)!
        self.mapView.addAnnotation(point)
    }
    
    func mapView(mapView: MGLMapView, didUpdateUserLocation userLocation: MGLUserLocation?) {
        if let userCoord = self.mapView.userLocation?.coordinate{
            mapView.setCenterCoordinate(userCoord, zoomLevel: 15, animated: false)
        }
        setMap()
    }
    
    func mapView(mapView: MGLMapView, imageForAnnotation annotation: MGLAnnotation) -> MGLAnnotationImage? {
        let filledImage = self.filledImageFrom(UIImage(named: "pin")!, color: UIColor(red: 0/255, green: 168/255, blue: 55/255, alpha: 1))
        let image = filledImage.textToImage("7")
        let annotationImage = MGLAnnotationImage(image: image, reuseIdentifier: "pin")
        return annotationImage
    }
    
    func mapView(mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
    
    
    
    override func viewDidLayoutSubviews() {
        //updateHeaderView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateHeaderView(){
        var headerRect = CGRect(x: 0, y: -tableHeaderHeight, width: table.bounds.width, height: tableHeaderHeight)
        if(table.contentOffset.y < -tableHeaderHeight){
            headerRect.origin.y = table.contentOffset.y
            headerRect.size.height = -table.contentOffset.y
        }
        
        headerView.frame = headerRect
    }
    
    //MARK: Table View methods
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        /*if(indexPath.row == 0){
            if let cell = tableView.dequeueReusableCellWithIdentifier(AVATAR_CELL_IDENTIFIER){
                return cell
            }
            
        } else {*/
        if(indexPath.row == 0){
            if(self.statisticsMode){
                if let cell = tableView.dequeueReusableCellWithIdentifier(STATISTICS_CELL_IDENTIFIER) as? TodayStatisticsCell{
                    if let hitTestView = self.view as? HitTestView{
                        hitTestView.cell0 = cell.segmentedControl
                    }
                    return cell
                }
            } else {
                if let cell = tableView.dequeueReusableCellWithIdentifier(AVATAR_CELL_IDENTIFIER) as? AvatarCell{
                    if let hitTestView = self.view as? HitTestView{
                        hitTestView.cell0 = cell.collectionView
                    }
                    return cell
                }
            }
            
        } else {
            if let cell = tableView.dequeueReusableCellWithIdentifier(CELL_IDENTIFIER) as? PlaceCellTableViewCell{
                cell.rightUtilityButtons = self.rightButtons() as [AnyObject]
                return cell
            }
        }
        return UITableViewCell()
    }
    
    func rightButtons() -> NSMutableArray{
        var array = NSMutableArray()
        array.sw_addUtilityButtonWithColor(UIColor.clearColor(), normalIcon: UIImage(named: "fav"), selectedIcon: UIImage(named: "fav_selected"))
        return array
    }
    
    /*
    - (NSArray *)leftButtons
    {
    NSMutableArray *leftUtilityButtons = [NSMutableArray new];
    
    [leftUtilityButtons sw_addUtilityButtonWithColor:
    [UIColor colorWithRed:0.07 green:0.75f blue:0.16f alpha:1.0]
    icon:[UIImage imageNamed:@"check.png"]];
    [leftUtilityButtons sw_addUtilityButtonWithColor:
    [UIColor colorWithRed:1.0f green:1.0f blue:0.35f alpha:1.0]
    icon:[UIImage imageNamed:@"clock.png"]];
    [leftUtilityButtons sw_addUtilityButtonWithColor:
    [UIColor colorWithRed:1.0f green:0.231f blue:0.188f alpha:1.0]
    icon:[UIImage imageNamed:@"cross.png"]];
    [leftUtilityButtons sw_addUtilityButtonWithColor:
    [UIColor colorWithRed:0.55f green:0.27f blue:0.07f alpha:1.0]
    icon:[UIImage imageNamed:@"list.png"]];
    
    return leftUtilityButtons;
    }
    */
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if(indexPath.row == 0){
            return 84
        } else {
            return 96
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        //updateHeaderView()
    }

    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if(indexPath.row != 0){
            return true
        } else {
            return false
        }
    }
    /*
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        var action = UITableViewRowAction(style: UITableViewRowActionStyle.Destructive, title: "Fav") { (action, ip) -> Void in
            
        }
        
        action.backgroundColor = UIColor.clearColor()
        return [action]
    }*/
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
       //MARK: CollectionViewDelegate & DataSource
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCellWithReuseIdentifier(COLLECTION_CELL_IDENTIFIER, forIndexPath: indexPath) as? AvatarCollectionViewCell{
            cell.avatarImage.image = UIImage(named: "example")
        
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print("select")
    }

    @IBAction func statisticsPressed(sender: AnyObject) {
        if(self.statisticsButton.selected){
            self.statisticsButton.selected = false
            self.statisticsMode = false
        } else {
            self.statisticsButton.selected = true
            self.statisticsMode = true
        }
    }
    
    @IBAction func userLocationPressed(sender: AnyObject) {
        
        if let loc = locationManager?.locationCoordinate{
            
//            let camera = MGLMapCamera(lookingAtCenterCoordinate: loc, fromEyeCoordinate: <#T##CLLocationCoordinate2D#>, eyeAltitude: <#T##CLLocationDistance#>)
           let camera = MGLMapCamera()
            camera.centerCoordinate = loc
//          mapView.setCamera(camera, withDuration: 5, animationTimingFunction: CAMediaTimingFunction(name: kCAMediaTimingFunctionDefault))
            mapView.setCenterCoordinate(loc, zoomLevel: 15, animated: false)
        }
    }
    
    @IBAction func mainBtnPressed(sender: AnyObject) {
        APP.i().moveCenterPanel()
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
