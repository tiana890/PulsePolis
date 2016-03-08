//
//  ContainerViewController.swift
//  GBU
//
//  Created by Agentum on 03.12.15.
//  Copyright © 2015 IMAC . All rights reserved.
//

import UIKit


class ContainerViewController: UIViewController, UIGestureRecognizerDelegate {
    
    let CONTAINER_OFFSET_VALUE: CGFloat = UIScreen.mainScreen().bounds.width - 60.0
    //let CONTAINER_OFFSET_VALUE:CGFloat = 260
    var GESTURE_RECOGNIZER_SCOPE: CGFloat = 40.0
    
    @IBOutlet weak var centerContainer: UIView!
    @IBOutlet weak var leftContainer: UIView!
    
    var centerController: UINavigationController?
    let CENTER_EMBED_SEGUE_IDENTIFIER = "centerEmbedSegue"
    
    @IBOutlet var centerLeadingContainerConstraint: NSLayoutConstraint!
   
    var gestureRecognizer = UIPanGestureRecognizer()
    var centerPanelOpen = true
    var translation: CGPoint?
    var velocity: CGPoint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        APP.i().containerController = self
        setInitialState()
    
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        centerLeadingContainerConstraint.addObserver(self, forKeyPath: "constant", options: NSKeyValueObservingOptions.New, context: nil)
    }
    func setInitialState(){
        
        gestureRecognizer.delegate = self
        gestureRecognizer.addTarget(self, action: "panRecognizerHandler:")
        centerContainer.addGestureRecognizer(self.gestureRecognizer)
        
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if(keyPath == "constant"){
            if let ch = change{
                if let newValue = ch["new"] as? CGFloat{
                    if(newValue == 0.0){
                        centerPanelOpen = true
                    } else if(newValue == CONTAINER_OFFSET_VALUE){
                        centerPanelOpen = false
                    }
                }
            }
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        centerLeadingContainerConstraint.removeObserver(self, forKeyPath: "constant")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func panRecognizerHandler(recognizer: UIPanGestureRecognizer){
        func deltaXFromPreviousPoint(point: CGPoint, toCurrent currentPoint: CGPoint) -> CGFloat{
            return currentPoint.x - point.x
        }
        
        if(gestureRecognizer.state == UIGestureRecognizerState.Began){
            translation = recognizer.locationInView(self.view)
            
        } else if(gestureRecognizer.state == UIGestureRecognizerState.Changed){
            
            let newTranslation = recognizer.locationInView(self.view)
            movePanelFromCurrentPositionToX(deltaXFromPreviousPoint(translation!, toCurrent: newTranslation))
            translation = newTranslation
            velocity = recognizer.velocityInView(self.view)
            
        } else if(gestureRecognizer.state == UIGestureRecognizerState.Ended){
            if let vel = velocity{
                if(vel.x < 0){
                    animatedPanelMoveViewToLeftEdge()
                } else {
                    animatedPanelMoveViewToRightEdge()
                }
            }
        }
    }
    
    func movePanelFromCurrentPositionToX(value: CGFloat){
       
        
        let newX = self.centerLeadingContainerConstraint.constant + value
        
        if(newX > 0 && newX < CONTAINER_OFFSET_VALUE){
            self.centerLeadingContainerConstraint.constant = newX
        } else{
            if(newX <= 0){
                self.centerLeadingContainerConstraint.constant = 0
            } else {
                self.centerLeadingContainerConstraint.constant = CONTAINER_OFFSET_VALUE
            }
        }
    }
    
    func animatedPanelMoveViewToLeftEdge(){
        animatedLeftPanelMoveToX(0.0)
        for(ch) in (self.centerController?.childViewControllers)!{
            ch.view.userInteractionEnabled = true
        }
    }
    
    func animatedPanelMoveViewToRightEdge(){
        animatedLeftPanelMoveToX(CONTAINER_OFFSET_VALUE)
        for(ch) in (self.centerController?.childViewControllers)!{
           ch.view.userInteractionEnabled = false
        }
    }
    
    func moveCenterPanel(){
        if(self.centerLeadingContainerConstraint.constant == 0){
            animatedPanelMoveViewToRightEdge()
        } else {
            animatedPanelMoveViewToLeftEdge()
        }
    }
    
    func animatedLeftPanelMoveToX(value: CGFloat){
        UIView.setAnimationDuration(1.0)
        //self.view.layoutIfNeeded()
        
        UIView.beginAnimations("move", context: nil)
        self.centerLeadingContainerConstraint.constant = value
        self.view.layoutIfNeeded()
        UIView.commitAnimations()
    }
    
   
    //MARK: -Gesture Recognizers Delegate
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        //It must be performed on the right edge of UIView
        if(self.centerPanelOpen){
            let panGestureRecongizer = gestureRecognizer as! UIPanGestureRecognizer
            
            if (panGestureRecongizer.velocityInView(self.view).x > 0.0){
                return true
            } else {
                return false
            }
        } else {
           return true
        }
    }
    
    //MARK: Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == CENTER_EMBED_SEGUE_IDENTIFIER){
            self.centerController = segue.destinationViewController as! UINavigationController
        }
    }
}
