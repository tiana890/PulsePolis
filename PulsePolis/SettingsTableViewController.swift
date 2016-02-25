//
//  SettingsPlaceSelectedCellSettingsTableViewController.swiftSettingsPlaceSelectedCell
//  PulsePolis
//
//  Created by IMAC  on 12.12.15.
//  Copyright © 2015 IMAC . All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SettingsTableViewController: BaseTableViewController, UISearchBarDelegate{
    let CELL_IDENTIFIER_HEADER = "headerCell"
    let CELL_IDENTIFIER_CITY = "cityCell"
    let CELL_IDENTIFIER_INDEX = "indexCell"
    let CELL_IDENTIFIER_SHOW_PLACES = "showPlaces"
    let CELL_IDENTIFIER_BAR = "barCell"
    let CELL_IDENTIFIER_CLUB = "clubCell"
    let CELL_IDENTIFIER_RESTAURANT = "restaurantCell"
    let CELL_IDENTIFIER_SEARCH = "searchCell"
    let CELL_IDENTIFIER_SHOW_FAVORITES = "showFavorites"
    let CELL_IDENTIFIER_PLACE = "placeCell"
    
    @IBOutlet var slider1: IndexSlider!
    @IBOutlet var slider2: IndexSlider!
    
    @IBOutlet var searchTable: UITableView!
    
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var lowerLabelHorizontalConstraint: NSLayoutConstraint!
    @IBOutlet var upperLabelHorizontalConstraint: NSLayoutConstraint!
    @IBOutlet var rangeSlider: NMRangeSlider!
    
    @IBOutlet var upperLabel: UILabel!
    @IBOutlet var lowerLabel: UILabel!
    @IBOutlet var placeSelectedImages: [UIImageView]!
    
    var subscribe: Disposable?
    
    var searchStr = ""
    var searchMode: Bool{
        if(searchStr.characters.count > 0){
            return true
        } else {
            return false
        }
    }
    var places: [Place]{
        get{
            if(!self.searchMode){
                
                return APP.i().places
            } else {
                return (APP.i().places.filter({ (place) -> Bool in
                    
                    return (place.name!.lowercaseString.containsString(self.searchStr.lowercaseString))
                }))
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.tabBar.hidden = true
        
        
        //        configureLabelSlider()
        //        updateSliderLabels()
        //        rangeSlider.lowerHandleImageNormal = UIImage(named: "slider_thumb")
        //        rangeSlider.upperHandleImageNormal = UIImage(named: "slider_thumb")
        //
        //        //UISearchBar.appearance().backgroundImage = UIImage(named: "search_bar_back")
        //        UISearchBar.appearance().backgroundColor = UIColor(red: 33.0/255.0, green: 40.0/255.0, blue: 47.0/255.0, alpha: 1.0)
        //        var txtField = searchBar.valueForKey("_searchField") as! UITextField
        //        txtField.backgroundColor = UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 0.3)
        //        txtField.textColor = UIColor(red: 235.0/255.0, green: 236.0/255.0, blue: 237.0/255.0, alpha: 0.3)
        //        //txtField.font = UIFont(name: "HelveticaNeue Thin", size: 11.0)
        self.tableView.allowsMultipleSelection = true
        
        let imageView = UIImageView(frame: self.view.frame)
        imageView.image = UIImage(named: "background_gradient")
        self.tableView.backgroundView = imageView
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named:"nav_background"), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = UIImage(named:"shadow_nav")
        self.navigationController?.navigationBar.translucent = true
        self.navigationController?.view.backgroundColor = UIColor.clearColor()

    }
    
    
//    override func viewWillDisappear(animated: Bool) {
//        let slider = NMRangeSlider()
//        if let containerView = APP.i().containerController?.centerContainer{
//            containerView.settingsRangeSlider = slider
//        }
//    }
//    
//    override func viewDidAppear(animated: Bool) {
//        super.viewDidAppear(animated)
//        if let containerView = APP.i().containerController?.centerContainer{
//            containerView.settingsRangeSlider = rangeSlider
//        }
//        
//    }
    
    @IBAction func backBtnPressed(sender: AnyObject) {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureLabelSlider()
    {
        self.rangeSlider.minimumValue = 0;
        self.rangeSlider.maximumValue = 9;
        
        self.rangeSlider.lowerValue = 0;
        self.rangeSlider.upperValue = 9;
        
        self.rangeSlider.minimumRange = 1;
        
        self.rangeSlider.stepValue = 1
        self.rangeSlider.stepValueContinuously = true
    }
    
    func updateSliderLabels(){
        var lowerCenter = CGPoint()
        lowerCenter.x = self.rangeSlider.lowerCenter.x + self.rangeSlider.frame.origin.x
        lowerCenter.y = self.rangeSlider.center.y
        
        var point = self.rangeSlider.convertPoint(lowerCenter, toView: self.rangeSlider.superview)
        self.lowerLabelHorizontalConstraint.constant = -point.x + 53
        self.lowerLabel.text = "\(self.rangeSlider.lowerValue)"
        
        var upperCenter = CGPoint()
        upperCenter.x = self.rangeSlider.upperCenter.x + self.rangeSlider.frame.origin.x
        upperCenter.y = self.rangeSlider.center.y
        self.upperLabel.text = "\(self.rangeSlider.upperValue)"
        
        var point2 = self.rangeSlider.convertPoint(upperCenter, toView: self.rangeSlider.superview)
        self.upperLabelHorizontalConstraint.constant = point2.x - 53
    }
    
    
    @IBAction func labelSliderChanged(sender: AnyObject) {
        self.updateSliderLabels()
    }
    
    func addToFavorites(place: Place){
        let favManager = FavoritesManager()
        
        favManager.addRemoveFromFavorites(Int(place.id!)!)
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if(section == 0){
            return 9
        } else {
            return self.places.count
        }
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if(indexPath.section == 1){
            if let cell = tableView.dequeueReusableCellWithIdentifier(CELL_IDENTIFIER_PLACE) as? SearchTableViewCell{
                cell.prepareForReuse()
                
                cell.name.text = self.places[indexPath.row].name ?? ""
                cell.btn.tag = indexPath.row
                cell.btn.addTarget(self, action: "btnPressed:", forControlEvents: .TouchUpInside)
                
                return cell
            }
        } else if(indexPath.section == 0){
            switch(indexPath.row){
            case 0:
                if let cell = tableView.dequeueReusableCellWithIdentifier(CELL_IDENTIFIER_HEADER){
                    return cell
                }
                break
            case 1:
                if let cell = tableView.dequeueReusableCellWithIdentifier(CELL_IDENTIFIER_CITY) as? SettingsCell{
                    cell.cityLabel.text = APP.i().city?.city ?? ""
                    return cell
                }
                break
            case 2:
                if let cell = tableView.dequeueReusableCellWithIdentifier(CELL_IDENTIFIER_INDEX) as? SettingsCell{
                    cell.configureRangeSlider()
                    return cell
                }
                break
            case 3:
                if let cell = tableView.dequeueReusableCellWithIdentifier(CELL_IDENTIFIER_SHOW_PLACES){
                    return cell
                }
                break
            case 4:
                if let cell = tableView.dequeueReusableCellWithIdentifier(CELL_IDENTIFIER_BAR) as? SettingsPlaceSelectedCell{
                    cell.btn.addTarget(self, action: "typeChanged:", forControlEvents: .TouchUpInside)
                    cell.btn.tag = 4
                    return cell
                }
                break
            case 5:
                if let cell = tableView.dequeueReusableCellWithIdentifier(CELL_IDENTIFIER_CLUB) as? SettingsPlaceSelectedCell{
                    cell.btn.addTarget(self, action: "typeChanged:", forControlEvents: .TouchUpInside)
                    cell.btn.tag = 5
                    return cell
                }
                break
            case 6:
                if let cell = tableView.dequeueReusableCellWithIdentifier(CELL_IDENTIFIER_RESTAURANT) as? SettingsPlaceSelectedCell{
                    cell.btn.addTarget(self, action: "typeChanged:", forControlEvents: .TouchUpInside)
                    cell.btn.tag = 6
                    return cell
                }
                break
            case 7:
                if let cell = tableView.dequeueReusableCellWithIdentifier(CELL_IDENTIFIER_SEARCH) as? SettingsCell
                {
                    cell.configureSearchCell()
                    cell.searchBar.setValue("Отмена", forKey:"_cancelButtonText")
                    cell.searchBar.delegate = self
                    
                    //                    addSubscription(cell.searchBar.rx_text.observeOn(MainScheduler.instance).subscribe({ (event) -> Void in
                    //                        if(!event.isStopEvent){
                    //                            if let str = event.element{
                    //                                if(str.characters.count > 0){
                    //                                    self.searchStr = str
                    //                                } else {
                    //                                    self.searchStr = ""
                    //                                }
                    //                            } else {
                    //                                self.searchStr = ""
                    //                            }
                    //
                    //                            self.tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .None)
                    //                        }
                    //                    }))
                    return cell
                }
                break
            case 8:
                if let cell = tableView.dequeueReusableCellWithIdentifier(CELL_IDENTIFIER_SHOW_FAVORITES){
                    return cell
                }
                break
            default:
                break
            }
        }
        return UITableViewCell()
    }
    
    func btnPressed(sender: UIButton){
        self.addToFavorites(self.places[sender.tag])
        self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: sender.tag, inSection: 1)], withRowAnimation: .None)
    }
    
    func typeChanged(sender: UIButton){
        switch(sender.tag){
        case 4:
            APP.i().settingsManager?.appendOrRemovePlaceType("bar")
            break
        case 5:
            APP.i().settingsManager?.appendOrRemovePlaceType("club")
            break
        case 6:
            APP.i().settingsManager?.appendOrRemovePlaceType("restaurant")
            break
        default:
            break
        }
        self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: sender.tag, inSection: 0)], withRowAnimation: .None)
    }
    
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if(indexPath.section == 0){
            switch(indexPath.row){
            case 0:
                return 64.0
            case 1:
                return 52.0
            case 2:
                return 97.0
            case 3:
                return 45.0
            case 4, 5, 6:
                return 52.0
            case 7:
                return 44.0
            case 8:
                return 45.0
            default:
                break
            }
            
        } else {
            return 52.0
        }
        return 0.0
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if(indexPath.section == 1){
            
            let favManager = FavoritesManager()
            
            if(favManager.favContainsPlace(Int(self.places[indexPath.row].id!)!)){
                cell.setSelected(true, animated: false)
            } else {
                cell.setSelected(false, animated: false)
            }
            
        } else if(indexPath.section == 0){
            switch(indexPath.row){
            case 4:
                if(APP.i().settingsManager!.ifContainsPlaceType("bar")){
                    cell.setSelected(true, animated: false)
                } else {
                    cell.setSelected(false, animated: false)
                }
                break
            case 5:
                if(APP.i().settingsManager!.ifContainsPlaceType("club")){
                    cell.setSelected(true, animated: false)
                } else {
                    cell.setSelected(false, animated: false)
                }
                break
            case 6:
                if(APP.i().settingsManager!.ifContainsPlaceType("restaurant")){
                    cell.setSelected(true, animated: false)
                } else {
                    cell.setSelected(false, animated: false)
                }
                break
            default:
                break
            }
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if(indexPath.section == 0){
            switch(indexPath.row){
            case 1:
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let pickerViewController = storyboard.instantiateViewControllerWithIdentifier("pickerControllerID")
                self.presentViewController(pickerViewController, animated: true, completion: nil)
                break
            case 4:
                APP.i().settingsManager?.appendOrRemovePlaceType("bar")
                break
            case 5:
                APP.i().settingsManager?.appendOrRemovePlaceType("club")
                break
            case 6:
                APP.i().settingsManager?.appendOrRemovePlaceType("restaurant")
                break
            default:
                break
            }
        }
        //        } else if(indexPath.section == 1){
        //            self.addToFavorites(self.places[indexPath.row])
        //            self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
        //        }
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        if(indexPath.section == 0){
            switch(indexPath.row){
            case 1:
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let pickerViewController = storyboard.instantiateViewControllerWithIdentifier("pickerControllerID")
                self.presentViewController(pickerViewController, animated: true, completion: nil)
                break
            case 4:
                APP.i().settingsManager?.appendOrRemovePlaceType("bar")
                break
            case 5:
                APP.i().settingsManager?.appendOrRemovePlaceType("club")
                break
            case 6:
                APP.i().settingsManager?.appendOrRemovePlaceType("restaurant")
                break
            default:
                break
            }
        }
        
        
    }
    
    //MARK: UISearchBarDelegate
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        searchBar.showsCancelButton = true
        if let uiButton = searchBar.valueForKey("cancelButton") as? UIButton{
            uiButton.setTitleColor(UIColor(red: 235.0/255.0, green: 236.0/255.0, blue: 237.0/255.0, alpha: 0.3)
                , forState: .Normal)
        }
        return true
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
    }
    
    func searchBarShouldEndEditing(searchBar: UISearchBar) -> Bool {
        searchBar.showsCancelButton = false
        return true
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarResultsListButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    func searchBarBookmarkButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchStr = searchText
        self.tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .None)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    
}
