//
//  ContainerViewController.swift
//  PulsePolis
//
//  Created by IMAC  on 22.11.15.
//  Copyright © 2015 IMAC . All rights reserved.
//

import UIKit
import QuartzCore

enum SlideOutState {
    case BothCollapsed
    case LeftPanelExpanded
}

class ContainerViewController: UIViewController, UIGestureRecognizerDelegate {
    
    let LEFT_PANEL_EMBED_SEGUE_IDENTIFIER = "leftEmbedSegue"
    let CENTER_PANEL_EMBED_SEGUE_IDENTIFIER = "centerEmbedSegue"

    var leftViewController: UIViewController?
    var centerViewController: UIViewController?
    
    let centerPanelExpandedOffset: CGFloat = 60
    
    @IBOutlet var centerContainerView: UIView!
    @IBOutlet var leftContainerView: UIView!
    var currentState: SlideOutState = .LeftPanelExpanded
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "handlePanGesture:")
        panGestureRecognizer.delegate = self
        //centerViewController!.view.addGestureRecognizer(panGestureRecognizer)
        //centerViewController!.view.frame.origin.x = UIScreen.mainScreen().bounds.size.width - centerPanelExpandedOffset
        centerContainerView.addGestureRecognizer(panGestureRecognizer)
        centerContainerView.frame.origin.x = UIScreen.mainScreen().bounds.size.width - centerPanelExpandedOffset

        print("\(UIScreen.mainScreen().bounds.size.width - centerPanelExpandedOffset)")
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Gesture recognizer
    func handlePanGesture(recognizer: UIPanGestureRecognizer) {
        let gestureIsDraggingFromLeftToRight = (recognizer.velocityInView(view).x > 0)
        
        switch(recognizer.state) {
        case .Began:
            if (currentState == .BothCollapsed) {
                if (gestureIsDraggingFromLeftToRight) {
                    
                }
            }
        case .Changed:
            recognizer.view!.center.x = recognizer.view!.center.x + recognizer.translationInView(view).x
            recognizer.setTranslation(CGPointZero, inView: view)
        case .Ended:
            if (leftViewController != nil) {
                // animate the side panel open or closed based on whether the view has moved more or less than halfway
                let hasMovedGreaterThanHalfway = recognizer.view!.center.x > view.bounds.size.width
                animateLeftPanel(shouldExpand: hasMovedGreaterThanHalfway)
            }
            default:
            break
        }
    }

    
    func toggleLeftPanel() {
        let notAlreadyExpanded = (currentState != .LeftPanelExpanded)
        
        if notAlreadyExpanded {
            
        }
        
        animateLeftPanel(shouldExpand: notAlreadyExpanded)
    }
    
    
    func collapseSidePanels() {
        switch (currentState) {
        case .LeftPanelExpanded:
            toggleLeftPanel()
        default:
            break
        }
    }
    /*
    func addLeftPanelViewController() {
        if (leftViewController == nil) {
            leftViewController = UIStoryboard.leftViewController()
            leftViewController!.animals = Animal.allCats()
            
            addChildSidePanelController(leftViewController!)
        }
    }
    
    func addChildSidePanelController(sidePanelController: SidePanelViewController) {
        sidePanelController.delegate = centerViewController
        
        view.insertSubview(sidePanelController.view, atIndex: 0)
        
        addChildViewController(sidePanelController)
        sidePanelController.didMoveToParentViewController(self)
    }*/
    
    
    func animateLeftPanel(shouldExpand shouldExpand: Bool) {
        if (shouldExpand) {
            currentState = .LeftPanelExpanded
            
            //animateCenterPanelXPosition(targetPosition: CGRectGetWidth(centerViewController!.view.frame) - centerPanelExpandedOffset)
            animateCenterPanelXPosition(targetPosition: CGRectGetWidth(self.centerContainerView.frame) - centerPanelExpandedOffset)
        } else {
            animateCenterPanelXPosition(targetPosition: 0) { finished in
                self.currentState = .BothCollapsed
                
            }
        }
    }
    
    func animateCenterPanelXPosition(targetPosition targetPosition: CGFloat, completion: ((Bool) -> Void)! = nil) {
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: {
            //self.centerViewController!.view.frame.origin.x = targetPosition
            self.centerContainerView.frame.origin.x = targetPosition
            }, completion: completion)
    }
    
  
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == LEFT_PANEL_EMBED_SEGUE_IDENTIFIER){
            self.leftViewController = segue.destinationViewController
        } else if(segue.identifier == CENTER_PANEL_EMBED_SEGUE_IDENTIFIER){
            self.centerViewController = segue.destinationViewController
        }
    }
    

}
