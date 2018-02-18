//
//  MemesPdfView.swift
//  ios-poc
//
//  Created by bohyung kim on 2018. 2. 18..
//  Copyright © 2018년 dsdstudio.inc. All rights reserved.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass
import PDFKit

class MemesPdfView:UIView {
    var editing:Bool = false
    var selectedAnnotation:PDFAnnotation? = nil
    var panGestureRecognizer:PDFAnnotationPanGestureRecognizer!
    var page:PDFPage? = nil
    var pdfScale:CGFloat = 1.0
    
    func setPage(page:PDFPage, width:CGFloat) {
        self.page = page
        let rect = page.pageRef!.getBoxRect(.mediaBox)
        let scale:CGFloat = width / (rect.width)
        self.pdfScale = scale
        print("pdfScale", pdfScale, width, rect)
        setNeedsDisplay()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        panGestureRecognizer = PDFAnnotationPanGestureRecognizer(target: self, action: #selector(annotationMoved(_:)))
        panGestureRecognizer.pdfView = self
        addGestureRecognizer(panGestureRecognizer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @objc func annotationMoved(_ g:PDFAnnotationPanGestureRecognizer) {
        let p = g.location(in: self)
        print(p)
    }
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()!
        
        context.saveGState()
        
        // 뒤집힌 PDF좌표계로 조정
        context.translateBy(x: 0.0, y: bounds.size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        context.scaleBy(x: pdfScale, y: pdfScale)
        if let page = self.page {
            context.drawPDFPage(page.pageRef!)
        }
        context.restoreGState()
    }
}

// TODO Implementation
class PDFAnnotationPanGestureRecognizer:UIPanGestureRecognizer {
    var pdfView:MemesPdfView? = nil
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        // validation check
        // annotation hittest
        // allow dragging
        if isEnabled && (pdfView?.editing)! {
            state = .began
        } else {
            state = .failed
        }
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        state = .changed
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        state = .ended
    }
}
