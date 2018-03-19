//
//  ColorSelectionCell.swift
//  ios-poc
//
//  Created by bohyung kim on 2018. 3. 19..
//  Copyright © 2018년 dsdstudio.inc. All rights reserved.
//

import UIKit

class ColorSelectionCell: UICollectionViewCell {
    var color:UIColor = UIColor.black {
        didSet {
            setNeedsDisplay()
        }
    }
    override func draw(_ rect: CGRect) {
        let p = UIBezierPath(ovalIn: rect.insetBy(dx: 5, dy: 5))
        
        color.setFill()
        p.fill()
    }
}
