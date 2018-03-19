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

extension UIColor {
    open class func randomColor() -> UIColor {
        let hue : CGFloat = CGFloat(arc4random() % 256) / 256 // use 256 to get full range from 0.0 to 1.0
        let saturation : CGFloat = CGFloat(arc4random() % 128) / 256 + 0.5 // from 0.5 to 1.0 to stay away from white
        let brightness : CGFloat = CGFloat(arc4random() % 128) / 256 + 0.5 // from 0.5 to 1.0 to stay away from black
        
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1)
    }
}
