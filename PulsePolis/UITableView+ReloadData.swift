//
//  UITableView+ReloadData.swift
//  PulsePolis
//
//  Created by IMAC  on 12.03.16.
//  Copyright © 2016 IMAC . All rights reserved.
//

import Foundation

extension UITableView {
    func reloadData(completion: ()->()) {
        UIView.animateWithDuration(0, animations: { self.reloadData() })
            { _ in completion() }
    }
}