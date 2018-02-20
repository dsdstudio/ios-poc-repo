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
        self.page?.displaysAnnotations = true
        let rect = page.pageRef!.getBoxRect(.mediaBox)
        let scale:CGFloat = width / (rect.width)
        self.pdfScale = scale
        print("pdfScale", pdfScale, width, rect, page.annotations)
        let a = PDFAnnotation(bounds: CGRect(origin:CGPoint(x:300, y:200), size:CGSize(width:100, height:100)), forType: .square, withProperties: nil)
        a.border = PDFBorder()
        a.border?.lineWidth = 5
        a.color = .red
        page.addAnnotation(a)
        setNeedsDisplay()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        panGestureRecognizer = PDFAnnotationPanGestureRecognizer(target: self, action:#selector(pan(_:)))
        panGestureRecognizer.pdfView = self
        panGestureRecognizer.delegate = self
        addGestureRecognizer(panGestureRecognizer)
        layer.drawsAsynchronously = true
    }
    
    @objc func pan(_ g:UIGestureRecognizer) {
        
    }
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()!
        context.interpolationQuality = .low
        context.saveGState()
        
        // 뒤집힌 PDF좌표계로 조정
        context.translateBy(x: 0.0, y: bounds.size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        context.scaleBy(x: pdfScale, y: pdfScale)
        self.page?.draw(with: .mediaBox, to: context)
        context.restoreGState()
    }
}

extension MemesPdfView:UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

class PDFAnnotationPanGestureRecognizer:UIPanGestureRecognizer {
    var pdfView:MemesPdfView? = nil
    var selectedAnnotation:PDFAnnotation? = nil
    var previousLocation:CGPoint? = nil
    
    /**
     annotation rect 기반으로 hittest
     **/
    func rectBasedHitTest(transform:CGAffineTransform, location:CGPoint) -> PDFAnnotation? {
        return (pdfView?.page?.annotations)!.reversed().filter({$0.bounds.applying(transform).contains(location)}).first
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        let location = touches.first?.location(in: pdfView)
        let transform = CGAffineTransform.identity
            .translatedBy(x: 0.0, y: (pdfView?.bounds.size.height)!)
            .scaledBy(x: 1, y: -1)
            .scaledBy(x: (pdfView?.pdfScale)!, y: (pdfView?.pdfScale)!)
        
        let selectedAnnotation = rectBasedHitTest(transform: transform, location: location!)
        if let annotation = selectedAnnotation {
            print("annotation selected ", annotation)
            self.selectedAnnotation = annotation
            self.previousLocation = location
        }

        if isEnabled && (pdfView?.editing)! {
            state = .began
        } else {
            state = .failed
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        if selectedAnnotation == nil {
            return
        }
        
        if let bounds = selectedAnnotation?.bounds,
            let p = touches.first?.location(in: pdfView),
            let previousLocation = self.previousLocation {
            
            let computedScale = 1 / (pdfView?.pdfScale)!
            let restoredTransform = CGAffineTransform(scaleX: computedScale, y: computedScale)
            let dp = CGPoint(x:p.x - previousLocation.x, y: p.y - previousLocation.y)
                .applying(restoredTransform)
            print(dp)
            selectedAnnotation?.bounds = CGRect(origin:CGPoint(x:bounds.origin.x + dp.x, y:bounds.origin.y - dp.y), size:bounds.size)
            pdfView?.setNeedsDisplay()
            self.previousLocation = p
            state = .changed
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        state = .ended
        selectedAnnotation = nil
        previousLocation = nil
    }
}
