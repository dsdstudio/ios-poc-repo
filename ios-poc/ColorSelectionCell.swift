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
    var text:String = "" {
        didSet {
            setNeedsDisplay()
        }
    }
    override func draw(_ rect: CGRect) {
        let p = UIBezierPath(ovalIn: rect.insetBy(dx: 5, dy: 5))
        color.setFill()
        p.fill()
        let s = self.text as NSString
        let font = UIFont.systemFont(ofSize: 17)
        let attr = [
            kCTFontAttributeName: UIFont.systemFont(ofSize: 17),
            kCTForegroundColorAttributeName: UIColor.red
        ]
        
        s.draw(in: CGRect(origin: CGPoint(x: rect.origin.x, y: rect.origin.y + (rect.size.height - font.lineHeight) * 0.5), size: rect.size), withAttributes: attr as [NSAttributedStringKey : Any])
    }
}
