//
//  CanvasView.swift
//  ios-poc
//
//  Created by bohyung kim on 2018. 2. 9..
//  Copyright © 2018년 dsdstudio.inc. All rights reserved.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass
import PDFKit

class CanvasView: PDFPage {
    var strokeGestureRecognizer:StrokeCollectGestureRecognizer!
    var path:UIBezierPath?
    var currrentStroke:Stroke {
        return strokeGestureRecognizer.currentStroke!
    }
    
    override func draw(with box: PDFDisplayBox, to context: CGContext) {
        super.draw(with: box, to: context)
        UIGraphicsPushContext(context)
        context.saveGState()
        
        context.restoreGState()
        UIGraphicsPopContext()
    }
}

class StrokeCollectGestureRecognizer:UIGestureRecognizer {
    var canvasView:UIView!
    var strokes:[Stroke] = []
    var currentStroke:Stroke? {
        return strokes.last
    }
    func appendTouches(touches:Set<UITouch>, event:UIEvent) {
        for touch in touches {
            currentStroke?.clearPredictedTouches()
            if let coalescedTouches = event.coalescedTouches(for: touch) {
                _ = coalescedTouches.map{ currentStroke?.points.append(PointData(location: $0.preciseLocation(in: canvasView))) }
            } else {
                currentStroke?.points.append(PointData(location: touch.preciseLocation(in: canvasView)))
            }
            if let predictedTouches = event.predictedTouches(for: touch) {
                _ = predictedTouches.map{ currentStroke?.points.append(PointData(location: $0.preciseLocation(in: canvasView), isPredicted:true))}
            }
        }
        canvasView.setNeedsDisplay()
    }
    
    func appendData(touch:UITouch, predicted:Bool = false) {
        var updateRect = CGRect.null
        let pointData = PointData(location: touch.preciseLocation(in: canvasView), isPredicted:predicted)
        currentStroke?.points.append(pointData)
    }
    
    func commitPath() {
        canvasView.setNeedsDisplay()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        let stroke = Stroke()
        strokes.append(stroke)
        appendTouches(touches: touches, event: event)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        appendTouches(touches: touches, event: event)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        print("cancelled")
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        print("ended")
        commitPath()
    }
    
    override func touchesEstimatedPropertiesUpdated(_ touches: Set<UITouch>) {
    }
}

// MARK :: Data Structures
class Stroke {
    var points:[PointData] = []
    func clearPredictedTouches () {
        points = points.filter{ !$0.isPredicted }
    }
}

class PointData {
    var _x:CGFloat = 0
    var _y:CGFloat = 0
    var location:CGPoint {
        get {
            return CGPoint(x: _x, y: _y)
        }
        set (v){
            _x = v.x
            _y = v.y
        }
    }
    var isPredicted = false
    
    init(location:CGPoint, isPredicted:Bool = false) {
        self.location = location
        self.isPredicted = isPredicted
    }
}
