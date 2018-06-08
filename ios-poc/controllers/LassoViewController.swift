//
//  LassoViewController.swift
//  ios-poc
//
//  Created by bohyung kim on 2018. 2. 21..
//  Copyright © 2018년 dsdstudio.inc. All rights reserved.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass

class LassoViewController: UIViewController {
    let segmentedControl:UISegmentedControl = {
        let v = UISegmentedControl()
        v.insertSegment(withTitle: "PEN", at: 0, animated: false)
        v.insertSegment(withTitle: "LASSO", at: 1, animated: false)
        v.selectedSegmentIndex = 0
        return v
    }()
    var lassoView:LassoView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        lassoView = LassoView(frame: view.frame)
        lassoView.backgroundColor = .white
        
        view.addSubview(lassoView)

        self.navigationItem.titleView = segmentedControl
        segmentedControl.addTarget(self, action: #selector(changed(_:)), for: UIControl.Event.valueChanged)
    }
    
    @objc func changed(_ sender:UISegmentedControl) {
        lassoView.drawingMode = PenDrawingConfig.DrawingMode(rawValue: sender.selectedSegmentIndex)!
    }
}

class PenDrawingConfig {
    enum DrawingMode:Int {
        case Pen = 0
        case Lasso = 1
    }
}

class PathCollectGestureRecognizer:UIGestureRecognizer {
    var lassoView:LassoView?
    
    override init(target: Any?, action: Selector?) {
        super.init(target: target, action: action)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        let touchLocation = (touches.first?.location(in: view))!
        lassoView?.activePath = UIBezierPath()
        lassoView?.activePath?.lineWidth = 3
        lassoView?.activePath?.move(to: touchLocation)
        state = .began
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        let touchLocation = (touches.first?.location(in: view))!
        lassoView?.activePath?.addLine(to: touchLocation)
        lassoView?.setNeedsDisplay()
        state = .changed
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        let l = CAShapeLayer()
        l.lineWidth = 3
        l.strokeColor = UIColor.black.cgColor
        l.fillColor = UIColor.clear.cgColor
        l.path = lassoView?.activePath?.cgPath
        lassoView?.layer.addSublayer(l)
        state = .ended
    }
}

class LassoToolGestureRecognizer:UIGestureRecognizer {
    var lassoView:LassoView?
    var selectedShapes = [CAShapeLayer]()
    var selected:Bool {
        get {
            return selectedShapes.count > 0
        }
    }
    
    func clearShadow(_ shape:CAShapeLayer) {
        shape.shadowColor = UIColor.clear.cgColor
        shape.shadowRadius = 0
        shape.shadowOpacity = 0
        shape.shadowOffset = .zero
    }
    
    func applyShadow(_ shape:CAShapeLayer) {
        shape.shadowColor = UIColor.darkGray.cgColor
        shape.shadowRadius = 4.0
        shape.shadowOpacity = 1
        shape.shadowOffset = .zero
    }
    
    func extractPoints(_ shapePath:CGPath) -> [CGPoint] {
        var arr = [CGPoint]()
        shapePath.applyWithBlock({ (element) in
            let type = element.pointee.type
            let points = element.pointee.points
            switch type {
            case .moveToPoint:
                arr.append(NSValue(cgPoint: points[0]).cgPointValue)
            case .addLineToPoint:
                arr.append(NSValue(cgPoint: points[0]).cgPointValue)
            case .addQuadCurveToPoint:
                // TODO curve 구현할것
                ()
            case .addCurveToPoint:
                ()
            case .closeSubpath:
                ()
            }
        })
        return arr
    }
    
    func newLassoPath () -> UIBezierPath {
        let lassoPath = UIBezierPath()
        lassoPath.lineWidth = 3
        lassoPath.lineCapStyle = .round
        lassoPath.lineJoinStyle = .round
        let dashes:[CGFloat] = [0.0, 8.0]
        lassoPath.setLineDash(dashes, count: dashes.count, phase: 0)
        return lassoPath
    }
    
    var previousPoint:CGPoint = .zero
    var dragMode = false
    var lassoLayer:LassoLayer? = nil
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        let touchLocation = (touches.first?.location(in: view))!
        state = .began
        if let l = lassoLayer {
            if (l.path?.contains(touchLocation))! && selected {
                print("선택된게 있넹", selectedShapes.count)
                previousPoint = touchLocation
                dragMode = true
                return
            }
            l.removeFromSuperlayer()
        }
        if let layers = lassoView?.layer.sublayers {
            layers.forEach({ clearShadow($0 as! CAShapeLayer) })
        }
        selectedShapes.removeAll()
        lassoView?.lassoPath = newLassoPath()
        lassoView?.lassoPath?.move(to: touchLocation)
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        let touchLocation = (touches.first?.location(in: view))!
        if dragMode {
            let delta = CGVector(dx: touchLocation.x - previousPoint.x, dy: touchLocation.y - previousPoint.y)
            CALayer.disableAnimation {
                self.lassoLayer?.position = CGPoint(x: (self.lassoLayer?.position.x)! + delta.dx, y: (self.lassoLayer?.position.y)! + delta.dy)
            }
            for s in self.selectedShapes {
                CALayer.disableAnimation {
                    s.position = CGPoint(x: s.position.x + delta.dx, y: s.position.y + delta.dy)
                }
            }
            previousPoint = touchLocation
        } else {
            lassoView?.lassoPath?.addLine(to: touchLocation)
            lassoView?.setNeedsDisplay()
        }
        state = .changed
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        if dragMode {
            dragMode = false
            previousPoint = .zero
            // 포지션을 기준으로 해서 좌표계를 변경한다.
            for s in selectedShapes {
                var t = CGAffineTransform(translationX: s.position.x, y: s.position.y)
                let p = s.path?.copy(using: &t)
                s.path = p
                CALayer.disableAnimation {
                    s.position = .zero
                }
            }
        } else {
            lassoView?.lassoPath?.close()
            let l = LassoLayer()
            l.path = lassoView?.lassoPath?.cgPath.copy()
            l.lineWidth = 3
            l.lineJoin = convertToCAShapeLayerLineJoin(convertFromCAShapeLayerLineJoin(CAShapeLayerLineJoin.round))
            l.lineCap = convertToCAShapeLayerLineCap(convertFromCAShapeLayerLineCap(CAShapeLayerLineCap.round))
            l.lineDashPattern = [0.0, 8.0]
            l.strokeColor = UIColor.blue.cgColor
            l.fillColor = UIColor(red: 29 / 255, green: 18/255, blue: 22/255, alpha: 0.1).cgColor
            lassoView?.layer.addSublayer(l)
            lassoLayer = l
            if let layers = lassoView?.layer.sublayers, let path = lassoView?.lassoPath {
                for shape in layers.filter({$0 is CAShapeLayer && !($0 is LassoLayer)}).map({$0 as! CAShapeLayer}).filter({ path.bounds.intersects(($0.path?.boundingBoxOfPath)!) }) {
                    let containsPoint = extractPoints(shape.path!).first(where: { (path.contains($0)) })
                    if containsPoint != nil {
                        applyShadow(shape)
                        selectedShapes.append(shape)
                    }
                }
            }
            lassoView?.lassoPath = nil
            lassoView?.setNeedsDisplay()
        }
        state = .ended
    }
}

class LassoLayer:CAShapeLayer {
    
}

class LassoView:UIView {
    var lassoPath:UIBezierPath? = UIBezierPath()
    var activePath:UIBezierPath? = nil
    var drawingMode:PenDrawingConfig.DrawingMode = .Pen {
        didSet (value) {
            switch drawingMode {
            case .Lasso:
                pathGesture?.isEnabled = false
                lassoGesture?.isEnabled = true
            case .Pen:
                pathGesture?.isEnabled = true
                lassoGesture?.isEnabled = false
            }
        }
    }
    var lassoGesture:LassoToolGestureRecognizer?
    var pathGesture:PathCollectGestureRecognizer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.drawsAsynchronously = true
        isUserInteractionEnabled = true
        lassoGesture = LassoToolGestureRecognizer(target: self, action: nil)
        lassoGesture?.lassoView = self
        lassoGesture?.isEnabled = false
        addGestureRecognizer(lassoGesture!)
        
        pathGesture = PathCollectGestureRecognizer(target: self, action: nil)
        pathGesture?.lassoView = self
        addGestureRecognizer(pathGesture!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func random(_ min:Int, _ max:Int) -> CGFloat {
        return CGFloat(min) + CGFloat(arc4random_uniform(UInt32(max - min + 1)))
    }
    
    override func draw(_ rect: CGRect) {
        let c = UIGraphicsGetCurrentContext()!
        if drawingMode == .Lasso {
            c.setStrokeColor(UIColor.blue.cgColor)
            c.setFillColor(UIColor(red: 29 / 255, green: 18/255, blue: 22/255, alpha: 0.1).cgColor)
            lassoPath?.stroke()
            lassoPath?.fill()
        }
        if drawingMode == .Pen {
            c.setStrokeColor(UIColor.black.cgColor)
            // configure
            activePath?.stroke()
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToCAShapeLayerLineJoin(_ input: String) -> CAShapeLayerLineJoin {
	return CAShapeLayerLineJoin(rawValue: input)
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromCAShapeLayerLineJoin(_ input: CAShapeLayerLineJoin) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToCAShapeLayerLineCap(_ input: String) -> CAShapeLayerLineCap {
	return CAShapeLayerLineCap(rawValue: input)
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromCAShapeLayerLineCap(_ input: CAShapeLayerLineCap) -> String {
	return input.rawValue
}
