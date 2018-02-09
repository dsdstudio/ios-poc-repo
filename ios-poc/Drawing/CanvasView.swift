//
//  CanvasView.swift
//  ios-poc
//
//  Created by bohyung kim on 2018. 2. 9..
//  Copyright © 2018년 dsdstudio.inc. All rights reserved.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass

class CanvasView: UIView {
    var strokeGestureRecognizer:StrokeCollectGestureRecognizer!
    var path:UIBezierPath?
    var currrentStroke:Stroke {
        return strokeGestureRecognizer.currentStroke!
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        path = UIBezierPath()
        path?.lineWidth = 3
        path?.lineCapStyle = .round
        path?.lineJoinStyle = .round
        strokeGestureRecognizer = StrokeCollectGestureRecognizer()
        strokeGestureRecognizer.canvasView = self
        
        addGestureRecognizer(strokeGestureRecognizer)
        
        layer.drawsAsynchronously = true
    }
    
    func newPDFContext() {
        UIGraphicsBeginPDFPageWithInfo(bounds, nil)
        
        UIGraphicsEndPDFContext()
    }

    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()!
        context.setStrokeColor(UIColor.black.cgColor)
        path?.stroke()
    }
}

class StrokeCollectGestureRecognizer:UIGestureRecognizer {
    var canvasView:CanvasView!
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
