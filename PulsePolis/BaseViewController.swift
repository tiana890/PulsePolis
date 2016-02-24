//
//  BaseViewController.swift
//  PulsePolis
//
//  Created by IMAC  on 06.01.16.
//  Copyright © 2016 IMAC . All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class BaseViewController: UIViewController {
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
