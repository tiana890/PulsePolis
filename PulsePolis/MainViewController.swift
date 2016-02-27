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
import RxSwift
import RxAlamofire
import SwiftyJSON
import AlamofireImage
import RAMAnimatedTabBarController


class MainViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, MGLMapViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, SWTableViewCellDelegate, UITabBarDelegate {
    
    let HEADER_CELL_IDENTIFIER = "headerCell"
    
    let CELL_IDENTIFIER = "placeCell"
    let AVATAR_CELL_IDENTIFIER = "avatarCell"
    let STATISTICS_CELL_IDENTIFIER = "statisticsCell"
    
    
    let COLLECTION_CELL_IDENTIFIER = "avatarCollectionViewCell"
    
    let AVATAR_SEGUE_IDENTIFIER = "avatarSegue"
    let SETTINGS_SEGUE_IDENTIFIER = "settingsSegue"
    
    var subscription: Disposable?
    var visitorsSubscription: Disposable?
    var favoritesSubscription: Disposable?
    
    var selectedAnnotation: MGLPointAnnotation?
    
    var statisticsMode = false
    var ifTodayMode = true
    
    @IBOutlet var cityLabel: UILabel!
    @IBOutlet var userLocationButton: UIButton!
    @IBOutlet var statisticsButton: UIButton!
    private let tableHeaderHeight: CGFloat = UIScreen.mainScreen().bounds.height - 49.0 - 180.0
    var headerView: UIView!
    @IBOutlet var mapView: MGLMapView!
    
    @IBOutlet var table: UITableView!
    
    @IBOutlet var actualLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    
    var places = [Place]()
    var selectedPlace: Place?
    
    var favorites: [Place]{
        get{
            
            let favManager = FavoritesManager()
            
            return self.places.filter({ (place) -> Bool in
                if let placeIdString = place.id{
                    if let placeId = Int(placeIdString){
                        if(favManager.favContainsPlace(placeId)){
                            return true
                        }
                    }
                }
                return false
            })
        }
    }
    
    var filteredPlaces: [Place]{
        get{
            if(!self.statisticsMode){
                return self.places.filter{APP.i().settingsManager?.isValid($0) == true}
            } else {
                return self.places
            }
        }
    }
    
    var annotations = [MGLPointAnnotation]()
    var annotationDict = [MGLPointAnnotation: String]()
    
    var visitors = [Visitor]()
    
    var cityId: String{
        get{
            if let cityid = APP.i().city?.id{
                return "\(cityid)"
            } else {
                return "1"
            }
        }
    }
    
    let sourceStringURL = "http://hotfinder.ru/hotjson/places.php?city_id="
    let visitorsSourceUrl = "http://hotfinder.ru/hotjson/visitors.php?place_id="
    let favoritesSourceUrl = "http://hotfinder.ru/hotjson/favorites.php"
    let todayStringUrl = "http://hotfinder.ru/hotjson/forecast.php?city_id="
    let statStringUrl = "http://hotfinder.ru/hotjson/stat.php?city_id="
    
    var ifLoading = false
    
    var locationManager: LocationManager?
    
    @IBOutlet var customTabBar: UITabBar!
    
    var refreshDate: NSDate?
    
    var favoritesMode = false
    
    var todayStatisticsManager = TodayStatisticsManager()
    
    var partialBackgroundView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = LocationManager()
        locationManager?.startLocationManager()
        
        mapView.delegate = self
        
        let styleURL = NSURL(string: "mapbox://styles/marinazayceva/cik6w72v300g1btj77hydn79p")
        mapView.styleURL = styleURL
        mapView.userInteractionEnabled = true
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .None
        
        
        var insets = table.contentInset
        insets.bottom = 44
        table.contentInset = insets
        
        self.refreshDate = NSDate()
        
        customizeTabBar()
        
        self.setTableBackground()
        
        self.loadPlaces()
        
    }
    
    func setTableBackground(){
        var height = self.tableHeaderHeight
        if(self.favoritesMode){
            height = (self.favorites.count == 0) ? 0 : UIScreen.mainScreen().bounds.height
        } else {
            height = (self.filteredPlaces.count == 0) ? 0 : UIScreen.mainScreen().bounds.height
        }
        
        let tableViewBackground = UIView(frame: self.table.frame)
        tableViewBackground.backgroundColor = UIColor.clearColor()
        partialBackgroundView = UIView(frame: CGRect(x: 0.0, y: self.tableHeaderHeight, width: UIScreen.mainScreen().bounds.width, height: height))
        partialBackgroundView.backgroundColor = UIColor(red: 33.0/255.0, green: 40.0/255.0, blue: 47.0/255.0, alpha: 1.0)
        
        tableViewBackground.addSubview(partialBackgroundView)
        self.table.backgroundView = tableViewBackground
        
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        var height = self.tableHeaderHeight
        if(self.favoritesMode){
            height = (self.favorites.count == 0) ? 0 : self.view.frame.height - (self.tableHeaderHeight - scrollView.contentOffset.y)
        } else {
            height = (self.filteredPlaces.count == 0) ? 0 : self.view.frame.height - (self.tableHeaderHeight - scrollView.contentOffset.y)
        }
        
        partialBackgroundView.frame = CGRect(x: 0.0, y: self.tableHeaderHeight - scrollView.contentOffset.y, width: UIScreen.mainScreen().bounds.width, height: height)
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBarHidden = false
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named:"nav_background"), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = UIImage(named:"shadow_nav")
        self.navigationController?.navigationBar.translucent = true
        self.navigationController?.view.backgroundColor = UIColor.clearColor()
        
        self.cityLabel.text = APP.i().city?.city ?? ""
    }
    
    func customizeTabBar(){
        
        let btnView = UIView(frame: CGRectMake(0.0, 0.0, UIScreen.mainScreen().bounds.width/3, 63.0))
        let btn = UIButton(type: .Custom)
        btn.frame = CGRectMake(0.0, 0.0, 78.0, 63.0)
        btn.addTarget(self, action: "mainButtonPressed:", forControlEvents: .TouchUpInside)
        btn.center = btnView.center
        btnView.addSubview(btn)
        
        btnView.center.x = UIScreen.mainScreen().bounds.width/2
        btnView.center.y = UIScreen.mainScreen().bounds.height - 63/2
        
        btn.setImage(UIImage(named:"tabbar_btn"), forState: .Normal)
        btn.setImage(UIImage(named:"tabbar_btn"), forState: .Highlighted)
        
        self.view.addSubview(btnView)
        
        self.customTabBar.selectedItem = self.customTabBar.items![0]
        
        for(item) in self.customTabBar.items!{
            item.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.whiteColor()], forState: .Normal)
            item.setTitleTextAttributes([NSForegroundColorAttributeName: ColorHelper.defaultColor], forState: .Selected)
        }
        
        self.customTabBar.delegate = self
        
        self.customTabBar.tintColor = ColorHelper.defaultColor
        self.customTabBar.barTintColor = UIColor.whiteColor()
        
    }
    

    func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        for(var i = 0; i < tabBar.items?.count; i++){
            if(item == tabBar.items![i]){
                if(i == 0){
                    self.favoritesMode = false
                    loadPlaces()
                } else if(i == 2){
                    self.favoritesMode = true
                    self.setMap()
                    self.table.reloadData()
                    if(self.favorites.count > 0){
                        if let placeId = self.favorites[0].id{
                            self.loadVisitors(placeId)
                        }
                    }
                }
            }
        }
    }
    
    func mainButtonPressed(button: UIButton){
        let bounceAnimation = RAMBounceAnimation()
        bounceAnimation.playAnimation(button.imageView!, textLabel: UILabel())
        self.favoritesMode = false
        if(!ifLoading){
            self.customTabBar.selectedItem = self.customTabBar.items![0]
            loadPlaces()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.locationManager?.stopLocationManager()
    }
    
    func setMap(){
        self.mapView.removeAnnotations(self.annotations)
        self.annotations.removeAll()
        self.annotationDict.removeAll()
        
        var array = self.filteredPlaces
        if(favoritesMode){
            array = self.favorites
        }
        
        for(place) in array{
            
            if let lat = place.lat{
                if let lon = place.lon{
                    let point = MGLPointAnnotation()
                    point.coordinate = CLLocationCoordinate2D(latitude: (lat as NSString).doubleValue, longitude: (lon as NSString).doubleValue)
                    self.annotations.append(point)
                    self.annotationDict[point] = place.id!
                    if(place == array.first!){
                        self.selectedAnnotation = point
                        self.selectedPlace = place
                    }
                    self.mapView.addAnnotation(point)
                }
            }
        }
        

        self.mapView.showAnnotations(self.annotations, animated: true)
    }
    
    func mapView(mapView: MGLMapView, didUpdateUserLocation userLocation: MGLUserLocation?) {
        
    }
    
    func mapView(mapView: MGLMapView, imageForAnnotation annotation: MGLAnnotation) -> MGLAnnotationImage? {
        
        var place: Place?
        if let placeId = self.annotationDict[annotation as! MGLPointAnnotation]{
            if let placeIndex = self.places.indexOf({ $0.id! == placeId}){
                place = self.places[placeIndex]
            }
        }
        
            let color: UIColor!
            if((annotation as! MGLPointAnnotation) == selectedAnnotation){
                color = ColorHelper.defaultColor
                //let filledImage = self.filledImageFrom(UIImage(named: "pin")!, color: color)
                let filledImage = UIImage(named:"annotation_select")!
                if let visIndex = place!.visitIndex{
                    let image = filledImage.textToImage(visIndex, selected: true)
                    let annotationImage = MGLAnnotationImage(image: image, reuseIdentifier: annotation.description)
                    return annotationImage
                } else {
                    let annotationImage = MGLAnnotationImage(image: filledImage, reuseIdentifier: annotation.description)
                    return annotationImage
                }
                
            } else {
                var color = UIColor.yellowColor()
                if let visIndex = place!.visitIndex{
                    color = ColorHelper.getColorByIndex(visIndex)
                }
                //let filledImage = self.filledImageFrom(UIImage(named: "pin")!, color: color)
                let filledImage = UIImage(named:self.imageNameByVisitIndex(place!.visitIndex))!
                if let visIndex = place!.visitIndex{
                    let image = filledImage.textToImage(visIndex, selected: false)
                    let annotationImage = MGLAnnotationImage(image: image, reuseIdentifier: place!.visitIndex!)
                    return annotationImage
                } else {
                    let annotationImage = MGLAnnotationImage(image: filledImage, reuseIdentifier: "notdefined")
                    return annotationImage
                }
            }
    //}
    
        return MGLAnnotationImage()
    }
    
    func imageNameByVisitIndex(visitIndex: String?) -> String{
        guard let vIndex = visitIndex else { return "" }
        switch(vIndex){
        case "0", "1":
            return "annotation0-1"
        case "2", "3":
            return "annotation2-3"
        case "4", "5", "6":
            return "annotation4-5-6"
        case "7", "8":
            return "annotation7-8"
        case "9", "10":
            return "annotation9-10"
        default:
            return ""
        }
    }
    
    
    func mapView(mapView: MGLMapView, didSelectAnnotation annotation: MGLAnnotation) {
        
        //Удаляем старую аннотацию
        if let previousSelectedAnnotation = self.selectedAnnotation{
            self.mapView.removeAnnotation(previousSelectedAnnotation)
            
            //Новая аннотация выделена
            self.selectedAnnotation = annotation as? MGLPointAnnotation
            self.mapView.removeAnnotation(annotation)
            
            self.mapView.addAnnotation(previousSelectedAnnotation)
            self.mapView.addAnnotation(annotation)
            
            self.selectedPlaceChanged()
        }
    }
    
    
    func selectedPlaceChanged(){
        
        self.places = self.places.sort({ (pl1, pl2) -> Bool in
            return Int(pl1.visitIndex!) > Int(pl2.visitIndex!)
        })
        
        if let placeId = self.annotationDict[self.selectedAnnotation!]{
            
            if let index = self.places.indexOf({ $0.id! == placeId}){
                let place = self.places[index]
                self.places.removeAtIndex(index)
                self.places.insert(place, atIndex: 0)
                self.selectedPlace = place
                
                self.loadVisitors(placeId)
            }
        }
        self.table.reloadData()
        
    }
    
    func mapView(mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: Table View methods
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if(indexPath.row == 0){
            if let headerCell = tableView.dequeueReusableCellWithIdentifier(HEADER_CELL_IDENTIFIER) as? MapHeaderViewCell{
                if let hitTestView = self.view as? HitTestView{
                    hitTestView.mapView = self.mapView
                    hitTestView.headerView = headerCell
                    
                    hitTestView.statisticsButton = headerCell.statisticsBtn
                    hitTestView.userLocationButton = headerCell.userLocationBtn
                    
                    hitTestView.table = self.table
                }
                headerCell.statisticsBtn.selected = self.statisticsMode
                headerCell.statisticsBtn.addTarget(self, action: "statisticsPressed:", forControlEvents: .TouchUpInside)
                headerCell.userLocationBtn.addTarget(self, action: "userLocationPressed:", forControlEvents: .TouchUpInside)
                return headerCell
            }
        } else if(indexPath.row == 1){
            if(self.statisticsMode){
                if let cell = tableView.dequeueReusableCellWithIdentifier(STATISTICS_CELL_IDENTIFIER) as? TodayStatisticsCell{
                    cell.prepareForReuse()
                    cell.segmentedControl.addTarget(self, action: "statisticsModeChanged:", forControlEvents: .ValueChanged)
                    cell.statisticsSegmentedControl.addTarget(self, action: "statisticsSegmentedControlValueChanged:", forControlEvents: .ValueChanged)
                    cell.todaySegmentedControl.addTarget(self, action: "todaySegmentedControlValueChanged:", forControlEvents: .ValueChanged)
                    cell.configureCell(self.todayStatisticsManager)
                    if let hitTestView = self.view as? HitTestView{
                        hitTestView.arrayOfViews.removeAll()
                        hitTestView.arrayOfViews.append(cell.segmentedControl)
                        hitTestView.arrayOfViews.append(cell.todaySegmentedControl)
                        hitTestView.arrayOfViews.append(cell.statisticsSegmentedControl)
                        
                    }
                    return cell
                }
            } else {
                if let cell = tableView.dequeueReusableCellWithIdentifier(AVATAR_CELL_IDENTIFIER) as? AvatarCell{
                    cell.prepareForReuse()
                    if let hitTestView = self.view as? HitTestView{
                        hitTestView.arrayOfViews.removeAll()
                        hitTestView.cell0 = cell.contentView
                    }
                    cell.collectionView.reloadData()
                    return cell
                }
            }
            
        } else {
            if let cell = tableView.dequeueReusableCellWithIdentifier(CELL_IDENTIFIER) as? PlaceCellTableViewCell{
                cell.prepareForReuse()
                cell.rightUtilityButtons = []
                cell.rightUtilityButtons = self.rightButtons(indexPath.row) as [AnyObject]
                for (button) in (cell.rightUtilityButtons as! [UIButton]){
                    button.tag = indexPath.row - 2
                    button.addTarget(self, action: "favButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
                }
                cell.delegate = self
                
                var place: Place?
                if(self.favoritesMode){
                    place = favorites[indexPath.row-2]
                } else {
                    place = filteredPlaces[indexPath.row-2]
                }
                
                cell.indexView.tag = 1234
                cell.configureCell(place!)
                cell.setNeedsDisplay()
                return cell
            }
        }
        return UITableViewCell()
    }
    
    
    func rightButtons(indexPathRow: Int) -> NSMutableArray{
        var array = NSMutableArray()
        array.sw_addUtilityButtonWithColor(UIColor.clearColor(), normalIcon: UIImage(named: "fav"), selectedIcon: UIImage(named: "fav_selected"))
        array[0].addTarget(self, action: "favButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        var place: Place?
        if(self.favoritesMode){
            place = favorites[indexPathRow-2]
        } else {
            place = filteredPlaces[indexPathRow-2]
        }
        
        let favManager = FavoritesManager()
        if(favManager.favContainsPlace(Int(place!.id!)!)){
            (array[0] as! UIButton).selected = true
        } else {
            (array[0] as! UIButton).selected = false
        }
        return array
    }
    
    func favButtonPressed(sender: UIButton){
        sender.selected = !sender.selected
    }
    
    func swipeableTableViewCell(cell: SWTableViewCell!, didTriggerRightUtilityButtonWithIndex index: Int) {
        if let c = cell as? PlaceCellTableViewCell{
            if let buttons = c.rightUtilityButtons{
                if let b = buttons[0] as? UIButton{
                    b.selected = !b.selected
                    
                    if let ip = self.table.indexPathForCell(cell){
                        if(!favoritesMode){
                            var place = self.filteredPlaces[ip.row - 2]
                            self.addToFavorites(place)
                        } else {
                            var place = self.favorites[ip.row - 2]
                            self.addToFavorites(place)
                        }
                    }
                }
            }
        }
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.setTableBackground()
        if(self.favoritesMode){
            return (self.favorites.count == 0) ? 0 : self.favorites.count + 2
        } else {
            return (self.filteredPlaces.count == 0) ? 0 : self.filteredPlaces.count + 2
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if(indexPath.row == 0){
            return self.tableHeaderHeight
        }
        else if(indexPath.row == 1){
            return 84
        } else {
            return 96
        }
    }
    
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func todaySegmentedControlValueChanged(sender: UISegmentedControl){
        //loadToday(["time":(sender.titleForSegmentAtIndex(sender.selectedSegmentIndex))])
        //        loadPlacesWithUrl(todayStringUrl + self.cityId, params: ["time":(sender.titleForSegmentAtIndex(sender.selectedSegmentIndex))!])
        //        print(["time":(sender.titleForSegmentAtIndex(sender.selectedSegmentIndex))!])
        self.todayStatisticsManager.todaySelectedSegmentIndex = sender.selectedSegmentIndex
        self.todayStatisticsManager.todayValue = sender.titleForSegmentAtIndex(sender.selectedSegmentIndex)
        loadPlaces()
    }
    
    func statisticsSegmentedControlValueChanged(sender: UISegmentedControl){
        self.todayStatisticsManager.statisticsSelectedSegmentIndex = sender.selectedSegmentIndex
        loadPlaces()
    }
    
    func statisticsModeChanged(sender: UISegmentedControl){
        print("modeChanged")
        self.todayStatisticsManager.segmentIndex = sender.selectedSegmentIndex
        loadPlaces()
    }
    
    
    //MARK: CollectionViewDelegate & DataSource
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCellWithReuseIdentifier(COLLECTION_CELL_IDENTIFIER, forIndexPath: indexPath) as? AvatarCollectionViewCell{
            let visitor = self.visitors[indexPath.row]
            cell.tag = indexPath.row
            cell.avatarImage.image = UIImage()
            if let avatarUrl = visitor.avatarUrl{
                self.createMaskForImage(cell.avatarImage)
                cell.avatarImage.af_setImageWithURL(NSURL(string: avatarUrl)!)
            }
            cell.name.text = visitor.name
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.visitors.count
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 16.0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(40.0, 84.0)
    }
    
    @IBAction func statisticsPressed(sender: UIButton) {
        self.statisticsMode = !sender.selected
        sender.selected = !sender.selected
        
        loadPlaces()
    }
    
    
    //NETWORK FUNCTIONS
    func loadPlaces(){
        ifLoading =  true
        var url = ""
        var params = [String: String]()
        if(self.statisticsMode){
            if(self.todayStatisticsManager.segmentIndex == 0){
                url = self.todayStringUrl
                params["time"] = self.todayStatisticsManager.todayValue ?? ""
            } else {
                url = self.statStringUrl
                params["day"] = "\(self.todayStatisticsManager.statisticsSelectedSegmentIndex)"
                params["time"] = self.todayStatisticsManager.statisticsTime ?? ""
            }
        } else {
            url = self.sourceStringURL
        }
        print(params)
        
        guard let cityId = APP.i().city?.id else { APP.i().defineCity({ () -> Void in
            self.loadPlaces()
        })
            return
        }
        url += cityId
        
        print(url)
        subscription = requestJSON(.GET, url, parameters: params, encoding: .URL, headers: nil)
            .observeOn(MainScheduler.instance)
            .debug()
            .subscribe(onNext: { (r, json) -> Void in
                let js = JSON(json)
                let status = js["status"]
                self.places.removeAll()
                if (status == "OK"){
                    self.refreshDate = NSDate()
                    if let arrayOfPlaces = js["places"].array{
                        for (j) in arrayOfPlaces{
                            let place = Place(json: j)
                            self.places.append(place)
                        }
                    }
                    self.setMap()
                    
                    if(self.filteredPlaces.count > 0 && !self.statisticsMode){
                        self.loadVisitors(self.filteredPlaces[0].id!)
                    } else {
                        self.visitors = []
                    }
                    APP.i().places = self.places
                    
                    self.table.reloadData()
                    self.ifLoading = false
                } else {
                    //ERROR MSG
                    self.ifLoading = false
                }
                
                }, onError: { (e) -> Void in
                    
                    
            })
        
    }
    
    

    func loadVisitors(placeId: String){
        visitorsSubscription = requestJSON(.GET, visitorsSourceUrl+placeId)
            .observeOn(MainScheduler.instance)
            .debug()
            .subscribe(onNext: { (r, json) -> Void in
                let js = JSON(json)
                let status = js["status"]
                if (status == "OK"){
                    self.visitors.removeAll()
                    if let arrayOfVisitors = js["visitors"].array{
                        for (j) in arrayOfVisitors{
                            let visitor = Visitor(json: j)
                            self.visitors.append(visitor)
                        }
                    }
                    self.table.reloadRowsAtIndexPaths([NSIndexPath(forRow: 1, inSection: 0)], withRowAnimation: .None)
                    
                } else {
                    //ERROR MSG
                }
                
                }, onError: { (e) -> Void in
                    
                    
            })
        addSubscription(visitorsSubscription!)
    }
    
    
    func addToFavorites(place: Place){
        let favManager = FavoritesManager()
        
        favManager.addRemoveFromFavorites(Int(place.id!)!)
    }
    
    
    @IBAction func userLocationPressed(sender: AnyObject) {
        
        if let loc = locationManager?.locationCoordinate{
            let camera = MGLMapCamera()
            camera.centerCoordinate = loc
            mapView.setCenterCoordinate(loc, zoomLevel: 15, animated: false)
        }
    }
    
    @IBAction func mainBtnPressed(sender: AnyObject) {
        
        APP.i().moveCenterPanel()
    }
    
    @IBAction func selectCity(sender: AnyObject) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let pickerViewController = storyboard.instantiateViewControllerWithIdentifier("pickerControllerID")
        self.navigationController?.pushViewController(pickerViewController, animated: true)
        
    }
    
//    func setActualLabel(){
//        let components = NSCalendar.currentCalendar().components([.Hour, .Minute], fromDate: NSDate())
//        let hour = components.hour
//        let minute = components.minute
//        self.actualLabel.hidden = false
//        self.timeLabel.hidden = false
//        
//        self.timeLabel.text = (minute > 10) ? "на \(hour):\(minute)" : " на \(hour):0\(minute)"
//    }
//    
//    func hideActualLabel(){
//        self.actualLabel.hidden = true
//        self.timeLabel.hidden = true
//    }
//    
    @IBAction func chooseTimePressed(sender: AnyObject) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let pickerViewController = storyboard.instantiateViewControllerWithIdentifier("pickerControllerID")
        pickerViewController.setValue(true, forKey: "ifTimePicker")
        self.navigationController?.pushViewController(pickerViewController, animated: true)
    }
    
    
    //MARK: Images
    
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
        
        let colouredImg = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return colouredImg
    }
    
    func createMaskForImage(image: UIImageView){
        let mask = CALayer()
        let maskImage = UIImage(named: "avatar_shape_small")
        mask.contents = maskImage?.CGImage
        mask.frame = CGRectMake(0, 0,maskImage!.size.width, maskImage!.size.height)
        image.layer.mask = mask
        image.layer.masksToBounds = true
        
    }
    
    //MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == AVATAR_SEGUE_IDENTIFIER){
            if let avatarCollectionVC = segue.destinationViewController as? AvatarCollectionViewController{
                print(self.selectedPlace?.id)
                avatarCollectionVC.place = self.selectedPlace
                avatarCollectionVC.visitors = self.visitors
                avatarCollectionVC.selectedIndex = sender!.tag
            }
        } 
    }
    
    func findPlaceWithPlaceId(placeId: String) -> Place?{
        if let index = self.places.indexOf({ $0.id == placeId }){
            
            return self.places[index]
        }
        return nil
    }
}
