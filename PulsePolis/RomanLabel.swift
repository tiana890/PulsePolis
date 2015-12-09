//
//  RomanLabel.swift
//  PulsePolis
//
//  Created by IMAC  on 09.12.15.
//  Copyright © 2015 IMAC . All rights reserved.
//

import UIKit

class RomanLabel: UILabel {

    override func drawRect(rect: CGRect) {
        self.font = UIFont(name: "HelveticaNeueCyr-Roman", size: 18.0)
    }

}
