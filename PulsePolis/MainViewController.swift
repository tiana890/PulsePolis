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
    
    var fromAvatar = false
    
    var ifAnimateCells = false
    
    @IBOutlet var cityLabel: UILabel!
    @IBOutlet var userLocationButton: UIButton!
    @IBOutlet var statisticsButton: UIButton!
    @IBOutlet var selectCityButton: UIButton!
    
    private let tableHeaderHeight: CGFloat = UIScreen.mainScreen().bounds.height - 49.0 - 180.0
    var headerView: UIView!
    @IBOutlet var mapView: MGLMapView!
    
    @IBOutlet var table: UITableView!
    
    @IBOutlet var actualLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    
    
    @IBOutlet var preloaderMapView: UIView!
    @IBOutlet var indicatorView: UIActivityIndicatorView!
    
    var places = [Place]()
    var selectedPlace: Place?
    
    var favorites: [Place]{
        get{
            
            let favManager = FavoritesManager()
            
            return self.filteredPlaces.filter({ (place) -> Bool in
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
    
    var ifLoading = false
    
    var locationManager: LocationManager?
    
    @IBOutlet var customTabBar: UITabBar!
    
    var refreshDate: NSDate?
    
    var favoritesMode = false
    
    var todayStatisticsManager = TodayStatisticsManager()
    
    var partialBackgroundView: UIView!
    
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = LocationManager()
        locationManager?.startLocationManager()
        
        mapView.delegate = self
        
        let styleURL = NSURL(string: "mapbox://styles/marinazayceva/cik6w72v300g1btj77hydn79p")
        mapView.styleURL = styleURL
        mapView.userInteractionEnabled = true
        APP.i().mapView = self.mapView
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .None
        
        
        var insets = table.contentInset
        insets.bottom = 44
        table.contentInset = insets
        
        self.refreshDate = NSDate()
        
        customizeTabBar()
        
        self.setTableBackground()
        self.showMapPreloader()
        
        APP.i().mainViewController = self
        
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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBarHidden = false
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named:"nav_background"), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = UIImage(named:"shadow_nav")
        self.navigationController?.navigationBar.translucent = true
        self.navigationController?.view.backgroundColor = UIColor.clearColor()
        
        self.cityLabel.text = APP.i().city?.city ?? ""
        
        if(self.fromAvatar){
            self.fromAvatar = false
        } else {
            self.loadPlaces(true)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if let hitTestView = self.view as? HitTestView{
            hitTestView.arrayOfViews.append(self.selectCityButton)
        }
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
        NSLayoutConstraint(item: btnView, attribute: .Bottom, relatedBy: .Equal, toItem: self.customTabBar, attribute: .Bottom, multiplier: 1.0, constant: 0.0).active = true
        
        self.customTabBar.selectedItem = self.customTabBar.items![0]
        
        for(item) in self.customTabBar.items!{
            item.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.whiteColor()], forState: .Normal)
            item.setTitleTextAttributes([NSForegroundColorAttributeName: ColorHelper.defaultColor], forState: .Selected)
        }
        
        self.customTabBar.delegate = self
        
        self.customTabBar.tintColor = ColorHelper.defaultColor
        self.customTabBar.barTintColor = UIColor.whiteColor()
        
        self.customTabBar.items![0].selectedImage = UIImage(named: "tabbar_all_selected")
        self.customTabBar.items![2].selectedImage = UIImage(named: "tabbar_fav_selected")
        
        print("BUTTON FRAME")
        print(btn.frame)
    }
    

    func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        for(var i = 0; i < tabBar.items?.count; i++){
            if(item == tabBar.items![i]){
                if(i == 0){
                    if(self.favoritesMode == false) { return }
                    self.favoritesMode = false
                    self.setMap()
                    self.table.hidden = false
                    self.ifAnimateCells = true
                    self.reloadTableAndResetAnimations()
                    if(self.filteredPlaces.count > 0){
                        if let placeId = self.filteredPlaces[0].id{
                            self.loadVisitors(placeId)
                        }
                    }
                    
                    
                } else if(i == 2){
                    if(self.favoritesMode == true) { return }
                    self.favoritesMode = true
                    self.ifAnimateCells = true
                    self.showMapPreloader()
                    setFavorites()
                }
            }
        }
    }
    
    func setFavorites(){
        self.setMap()
        self.reloadTableAndResetAnimations()
        
        if(self.favorites.count > 0){
            if let placeId = self.favorites[0].id{
                self.loadVisitors(placeId)
            }
        } else {
            self.table.hidden = true
        }
    }
    
    func mainButtonPressed(button: UIButton){
        let bounceAnimation = RAMBounceAnimation()
        bounceAnimation.playAnimation(button.imageView!, textLabel: UILabel())
        //self.favoritesMode = false
        self.ifAnimateCells = true
        if(!ifLoading){
            //self.customTabBar.selectedItem = self.customTabBar.items![0]
            loadPlaces(false)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
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
        
        self.mapView.showAnnotations(self.annotations, edgePadding: UIEdgeInsets(top: 40.0, left: 30.0, bottom: UIScreen.mainScreen().bounds.height - self.tableHeaderHeight + 30.0, right: 30.0), animated: false)
        
    }
    
    func showMapPreloader(){
        self.preloaderMapView.hidden = false
        self.indicatorView.startAnimating()
    }
    
    func hideMapPreloader(){
        self.preloaderMapView.hidden = true
        self.indicatorView.stopAnimating()
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
            if((annotation as! MGLPointAnnotation) == selectedAnnotation){
                if let visIndex = place!.visitIndex{
                    var image = UIImage(named: "\(visIndex)_ann_select")!
                    image = image.imageWithAlignmentRectInsets(UIEdgeInsets(top: 0.0, left: 0.0, bottom: image.size.height/2, right: 0.0))
                    let annotationImage = MGLAnnotationImage(image: image, reuseIdentifier: "\(visIndex)")
                    return annotationImage
                } else {
                    let image = UIImage()
                    let annotationImage = MGLAnnotationImage(image: image, reuseIdentifier: "selected")
                    return annotationImage
                }
                
            } else {
                if let visIndex = place!.visitIndex{
                    var image = UIImage(named: "\(visIndex)_ann")!
                    image = image.imageWithAlignmentRectInsets(UIEdgeInsets(top: 0.0, left: 0.0, bottom: image.size.height/2, right: 0.0))
                    let annotationImage = MGLAnnotationImage(image: image, reuseIdentifier: "selected\(visIndex)")
                    
                    return annotationImage
                } else {
                    let image = UIImage()
                    let annotationImage = MGLAnnotationImage(image: image, reuseIdentifier: "notdefined")
                    return annotationImage
                }
            }
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
            if let ann = annotation as? MGLPointAnnotation{
                if(ann == previousSelectedAnnotation){
                    return
                }
                
                self.mapView.removeAnnotation(previousSelectedAnnotation)
                
                //Новая аннотация выделена
                self.selectedAnnotation = ann
                self.mapView.removeAnnotation(annotation)
                
                self.mapView.addAnnotation(previousSelectedAnnotation)
                self.mapView.addAnnotation(ann)
                
                self.selectedPlaceChanged()
            }
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
        self.reloadTableAndResetAnimations()
        
    }
    
    //MARK: MapViewDelegate methods

    
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
                cell.ifAnimate = self.ifAnimateCells
                cell.configureCell(place!)
                
                cell.tag = indexPath.row
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
                            let place = self.filteredPlaces[ip.row - 2]
                            self.addToFavorites(place)
                        } else {
                            let place = self.favorites[ip.row - 2]
                            self.addToFavorites(place)
                        }
                    }
                    if(self.favoritesMode){
                        self.setFavorites()
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
            if(self.favoritesMode){
                return (self.favorites.count == 0) ? 0 : self.tableHeaderHeight
            } else {
                return (self.filteredPlaces.count == 0) ? 0 : self.tableHeaderHeight
            }
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
        self.todayStatisticsManager.todaySelectedSegmentIndex = sender.selectedSegmentIndex
        self.todayStatisticsManager.todayValue = sender.titleForSegmentAtIndex(sender.selectedSegmentIndex)
        if(!ifLoading){
            
           
            loadPlaces(false)
            
        }
    }
    
    func statisticsSegmentedControlValueChanged(sender: UISegmentedControl){
        self.todayStatisticsManager.statisticsSelectedSegmentIndex = sender.selectedSegmentIndex
        if(!ifLoading){
            
            loadPlaces(false)
            
        }
    }
    
    func statisticsModeChanged(sender: UISegmentedControl){
        print("modeChanged")
        self.todayStatisticsManager.segmentIndex = sender.selectedSegmentIndex
        if(!ifLoading){
           
            loadPlaces(false)
            
        }
    }
    
    
    //MARK: CollectionViewDelegate & DataSource
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCellWithReuseIdentifier(COLLECTION_CELL_IDENTIFIER, forIndexPath: indexPath) as? AvatarCollectionViewCell{
            let visitor = self.visitors[indexPath.row]
            cell.prepareForReuse()
            cell.tag = indexPath.row
            cell.viewWithTag(12345)?.removeFromSuperview()
            cell.avatarImage.image = UIImage(named:"ava_small")!
            
            let indicatorView = UIActivityIndicatorView(activityIndicatorStyle: .White)
            indicatorView.center = cell.avatarImage.center
            indicatorView.tag = 12345
            cell.contentView.addSubview(indicatorView)
            indicatorView.startAnimating()
            
            let filter = AspectScaledToFillSizeFilter(size: CGSizeMake(cell.avatarImage.frame.width, cell.avatarImage.frame.height))
            if let avatarUrl = visitor.avatarUrl{
                if let url = NSURL(string: avatarUrl){
                    self.createMaskForImage(cell.avatarImage)
                    cell.avatarImage.af_setImageWithURL(
                        url,
                        placeholderImage: nil,
                        filter: filter,
                        imageTransition: .CrossDissolve(0.5),
                        completion: { response in
                            indicatorView.hidden = true
                            indicatorView.stopAnimating()
                            
                        }
                    )
                }
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
        if(!ifLoading){
            loadPlaces(true)
        }
    }
    
    
    //NETWORK FUNCTIONS
    func loadPlaces(mapPreloader: Bool){
        ifLoading =  true
        
        guard let cityId = APP.i().city?.id else {
            self.ifLoading = false
            APP.i().defineCity({ () -> Void in
                self.cityLabel.text = APP.i().city?.city ?? ""
                self.loadPlaces(mapPreloader)
            })
            return
        }
        
        
        if(mapPreloader){
            self.showMapPreloader()
            self.table.hidden = true
        }
        
        let queue = dispatch_queue_create("placesQueue",nil)
        
        let networkClient = NetworkClient()
        
        let observePlaces = self.createObservableForPlaces()
        observePlaces.observeOn(ConcurrentDispatchQueueScheduler(queue: queue)).subscribe(onNext: { (placesResponse) -> Void in
            self.loadPlacesHandler(placesResponse)
            }, onError: { (errorType) -> Void in
                networkClient.updateSettings().observeOn(ConcurrentDispatchQueueScheduler(queue: queue)).subscribeNext({ (networkResponse) -> Void in
                    if(networkResponse.status == Status.Success){
                        let newObserverForPlaces = self.createObservableForPlaces()
                        newObserverForPlaces.observeOn(ConcurrentDispatchQueueScheduler(queue: queue)).subscribeNext({ (networkResponse) -> Void in
                            self.loadPlacesHandler(networkResponse)
                        }).addDisposableTo(self.disposeBag)
                    } else{
                        self.showAlert("Ошибка", msg: "Данные не могут быть загружены")
                        self.reloadTableAndResetAnimations()
                    }
                    
                    
                }).addDisposableTo(self.disposeBag)
            }, onCompleted: { () -> Void in
                
                
            }) { () -> Void in
                
        }.addDisposableTo(self.disposeBag)
    }
    
    func loadPlacesHandler(placesResponse: NetworkResponse){
        if let response = placesResponse as? PlacesResponse{
            if(placesResponse.status == Status.Success){
                if let _places = response.places{
                    self.places = _places
                    
                    if(self.favoritesMode && self.favorites.count > 0){
                        self.loadVisitors(self.favorites[0].id!)
                    } else if(self.filteredPlaces.count > 0 && !self.statisticsMode && !self.favoritesMode){
                        self.loadVisitors(self.filteredPlaces[0].id!)
                    } else if(!self.statisticsMode){
                        self.table.hidden = true
                        self.visitors = []
                    } else if(statisticsMode){
                        self.table.hidden = false
                        self.visitors = []
                    }
                    APP.i().places = self.places
                    
                    dispatch_async(dispatch_get_main_queue()) { () -> Void in
                        self.setMap()
                       
                        self.reloadTableAndResetAnimations()
                    }
                }
            } else {
                //ALERT!!!
            }
        }
    }
    
    func reloadTableAndResetAnimations(){
        self.table.reloadData { () -> () in
            self.ifAnimateCells = false
            self.ifLoading = false
            
            self.hideMapPreloader()
        }
    }
    
    func createObservableForPlaces() -> Observable<NetworkResponse>{
        let networkClient = NetworkClient()
        let observePlaces:Observable<NetworkResponse>!
        if(self.statisticsMode){
            if(self.todayStatisticsManager.segmentIndex == 0){
                observePlaces = networkClient.getForecastPlaces(cityId ?? "", time: self.todayStatisticsManager.todayValue ?? "")
            } else {
                observePlaces = networkClient.getStatisticsPlaces(cityId ?? "", time: self.todayStatisticsManager.statisticsTimeString ?? "", day: "\(self.todayStatisticsManager.statisticsSelectedSegmentIndex)")
            }
        } else {
            observePlaces = networkClient.getPlaces(cityId ?? "")
        }
        return observePlaces
    }
    
    func loadVisitors(placeId: String){
        
        dispatch_async(dispatch_queue_create("qqq", nil)) { () -> Void in
            let queue = dispatch_queue_create("queue",nil)
            
            if(self.visitors.count > 0){
                self.visitors.removeAll()
                dispatch_async(dispatch_get_main_queue()) { () -> Void in
                    if let cell = self.table.cellForRowAtIndexPath(NSIndexPath(forItem: 1, inSection: 0)) as? AvatarCell{
                        print(cell)
                        let indicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
                        indicator.center = cell.contentView.center ?? CGPoint(x: 0,y: 0)
                        indicator.tag = 5555
                        
                        cell.contentView.addSubview(indicator)
                        indicator.startAnimating()
                        cell.collectionView.hidden = true
                    }
                    
                }
                
                //self.table.reloadRowsAtIndexPaths([NSIndexPath(forRow: 1, inSection: 0)], withRowAnimation: .None)
            }
            
            let networkClient = NetworkClient()
            
            networkClient.getVisitors(placeId).observeOn(ConcurrentDispatchQueueScheduler(queue: queue))
                .subscribe(onNext: { (networkResponse) -> Void in
                    self.loadVisitorsHandler(networkResponse)
                    }, onError: { (errorType) -> Void in
                        networkClient.updateSettings().observeOn(MainScheduler.instance).subscribeNext({ (networkResponse) -> Void in
                            if(networkResponse.status == Status.Success){
                                networkClient.getVisitors(placeId).observeOn(ConcurrentDispatchQueueScheduler(queue: queue))
                                    .subscribeNext({ (networkResponse) -> Void in
                                        self.loadVisitorsHandler(networkResponse)
                                    }).addDisposableTo(self.disposeBag)
                            } else{
                                self.showAlert("Ошибка", msg: "Данные не могут быть загружены")
                                self.reloadTableAndResetAnimations()
                            }
                            
                        }).addDisposableTo(self.disposeBag)
                    }, onCompleted: { () -> Void in
                        
                    }, onDisposed: { () -> Void in
                        
                }).addDisposableTo(self.disposeBag)
        }
       
    }
    
    func loadVisitorsHandler(visitorsResponse: NetworkResponse){
        
            if let response = visitorsResponse as? VisitorsResponse{
                if (response.status == Status.Success){
                    self.visitors.removeAll()
                    if let arrayOfVisitors = response.visitors{
                        self.visitors = arrayOfVisitors
                    }

                    dispatch_async(dispatch_get_main_queue()) { () -> Void in
                        if(self.table.hidden){
                            self.table.reloadData()
                            self.table.hidden = false
                        }
                        if let cell = self.table.cellForRowAtIndexPath(NSIndexPath(forItem: 1, inSection: 0)) as? AvatarCell{
                            cell.contentView.viewWithTag(5555)?.removeFromSuperview()
                            cell.collectionView.hidden = false
                        }

                        self.table.reloadRowsAtIndexPaths([NSIndexPath(forRow: 1, inSection: 0)], withRowAnimation: .None)
                    }
                
                } else {
                    self.showAlert("Ошибка", msg: "Данные не могут быть загружены")
                    self.reloadTableAndResetAnimations()
                }
            }
        
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
    
    
    @IBAction func statisticsTimePressed(sender: AnyObject) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let pickerViewController = storyboard.instantiateViewControllerWithIdentifier("pickerControllerID") as? PickerViewController{
            pickerViewController.ifDate = true
            pickerViewController.sourceController = self
            self.presentViewController(pickerViewController, animated: true, completion: nil)
        }
    }
    
    @IBAction func selectCity(sender: AnyObject) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let pickerViewController = storyboard.instantiateViewControllerWithIdentifier("pickerControllerID")
        self.presentViewController(pickerViewController, animated: true, completion: nil)
    }
    

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
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if(indexPath.row > 1){
                if(!self.ifLoading){
                    let cell = self.table.cellForRowAtIndexPath(indexPath)
                    self.performSegueWithIdentifier(AVATAR_SEGUE_IDENTIFIER, sender: cell)
            }
            
        }
    }
    

    //MARK: Scroll delegate
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        var height = self.tableHeaderHeight
        if(self.favoritesMode){
            height = (self.favorites.count == 0) ? 0 : self.view.frame.height - (self.tableHeaderHeight - scrollView.contentOffset.y)
        } else {
            height = (self.filteredPlaces.count == 0) ? 0 : self.view.frame.height - (self.tableHeaderHeight - scrollView.contentOffset.y)
        }
        
        partialBackgroundView.frame = CGRect(x: 0.0, y: self.tableHeaderHeight - scrollView.contentOffset.y, width: UIScreen.mainScreen().bounds.width, height: height)
       
    }
    

    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if(scrollView.contentOffset.y <= 100.0 && scrollView.contentOffset.y > 0.0){
            scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        }
    }
    
    //MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == AVATAR_SEGUE_IDENTIFIER){
            if let avatarCollectionVC = segue.destinationViewController as? AvatarCollectionViewController{
               
                if let _ = sender as? UITableViewCell{
                    var place: Place?
                    if(self.favoritesMode){
                        if let index = sender?.tag{
                            if(favorites.count > index-2){
                                place = favorites[index-2]
                            }
                        }
                    } else {
                        if let index = sender?.tag{
                            if(filteredPlaces.count > index-2){
                                place = filteredPlaces[index-2]
                            }
                        }

                    }
                    
                    avatarCollectionVC.place = place
                    avatarCollectionVC.ifLoadVisitors = true
                    avatarCollectionVC.sourceController = self
                    
                } else {
                    print(sender?.tag)
                    avatarCollectionVC.place = self.selectedPlace
                    avatarCollectionVC.visitors = self.visitors
                    avatarCollectionVC.selectedIndex = sender!.tag
                    avatarCollectionVC.sourceController = self
                }
            }
        } 
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if(identifier == AVATAR_SEGUE_IDENTIFIER){
            if(self.ifLoading){
                return false
            }
        }
        return true
    }
    
    func findPlaceWithPlaceId(placeId: String) -> Place?{
        if let index = self.places.indexOf({ $0.id == placeId }){
            
            return self.places[index]
        }
        return nil
    }
    

    
    //MARK: Alerts
    func showAlert(title: String, msg: String){
        let alert = UIAlertController(title: title,
            message: msg,
            preferredStyle: UIAlertControllerStyle.Alert)
        
        let cancelAction = UIAlertAction(title: "OK",
            style: .Cancel, handler: nil)
        
        alert.addAction(cancelAction)
        UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
        
    }
}
