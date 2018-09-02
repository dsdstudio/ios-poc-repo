//
//  CustomScrollView.swift
//  ios-poc
//
//  Created by bohyung kim on 02/09/2018.
//  Copyright © 2018 dsdstudio.inc. All rights reserved.
//

import UIKit

class CustomScrollView: UIScrollView, UIGestureRecognizerDelegate {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.panGestureRecognizer.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer is UIPanGestureRecognizer && otherGestureRecognizer is UIPanGestureRecognizer {
            print("둘다 패닝")
            print(gestureRecognizer.view, otherGestureRecognizer.view)
        }
        return false
    }
    
}
