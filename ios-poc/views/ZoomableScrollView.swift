//
//  ZoomableScrollView.swift
//  RemotePDFViewer
//
//  Created by bohyung kim on 2018. 2. 5..
//  Copyright © 2018년 dsdstudio.inc. All rights reserved.
//

import UIKit

class ZoomableScrollView: UIScrollView, UIGestureRecognizerDelegate {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.pinchGestureRecognizer?.delegate = self
        self.panGestureRecognizer.minimumNumberOfTouches = 2
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
