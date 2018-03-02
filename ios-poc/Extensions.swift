//
//  Extensions.swift
//  ios-poc
//
//  Created by bohyung kim on 2018. 3. 2..
//  Copyright © 2018년 dsdstudio.inc. All rights reserved.
//

import UIKit

extension CALayer {
    open class func disableAnimation(_ f:() -> Void) {
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
            f()
        CATransaction.commit()
    }
}
