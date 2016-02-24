//
//  BaseTableViewController.swift
//  PulsePolis
//
//  Created by IMAC  on 07.02.16.
//  Copyright © 2016 IMAC . All rights reserved.
//


import UIKit
import RxSwift

class BaseTableViewController: UITableViewController {
    var mSubscriptions: CompositeDisposable?
    
    func addSubscription(subscription: Disposable){
        if(mSubscriptions == nil){
            mSubscriptions = CompositeDisposable()
        }
        if let mSub = mSubscriptions{
            mSub.addDisposable(subscription)
        }
    }
    
    func unsubscribeAll(){
        if let mSub = mSubscriptions{
            mSub.dispose()
            var subs: CompositeDisposable?
            mSubscriptions = subs
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeAll()
    }
    
    
}
