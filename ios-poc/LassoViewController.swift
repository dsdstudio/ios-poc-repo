//
//  LassoViewController.swift
//  ios-poc
//
//  Created by bohyung kim on 2018. 2. 21..
//  Copyright © 2018년 dsdstudio.inc. All rights reserved.
//

import UIKit

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
        
        segmentedControl.frame = CGRect(origin: CGPoint(x:15, y:22), size: CGSize(width: 200, height: 44))
        segmentedControl.addTarget(self, action: #selector(changed(_:)), for: .valueChanged)
        view.addSubview(segmentedControl)
    }
    
    @objc func changed(_ sender:UISegmentedControl) {
        print(sender.selectedSegmentIndex)
        lassoView.drawingMode = DrawingMode(rawValue: sender.selectedSegmentIndex)!
    }
}
enum DrawingMode:Int {
    case Pen = 0
    case Lasso = 1
}

class LassoView:UIView {
    var lassoPath:UIBezierPath? = nil
    var activePath:UIBezierPath? = nil
    var selectedShapes = [CAShapeLayer]()
    var drawingMode:DrawingMode = .Pen
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.drawsAsynchronously = true
        isUserInteractionEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func random(_ min:Int, _ max:Int) -> CGFloat {
        return CGFloat(min) + CGFloat(arc4random_uniform(UInt32(max - min + 1)))
    }
    
    func clearShadow(_ shape:CAShapeLayer) {
        shape.shadowColor = UIColor.clear.cgColor
        shape.shadowRadius = 0
        shape.shadowOpacity = 0
        shape.shadowOffset = .zero
    }
    
    func applyShadow(_ shape:CAShapeLayer) {
        shape.shadowColor = UIColor.darkGray.cgColor
        shape.shadowRadius = 8.0
        shape.shadowOpacity = 0.9
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touchLocation = (touches.first?.location(in: self))!
        switch drawingMode {
        case .Pen:
            activePath = UIBezierPath()
            activePath?.lineWidth = 3
            activePath?.move(to: touchLocation)
        case .Lasso:
            if let layers = layer.sublayers {
                layers.forEach({ clearShadow($0 as! CAShapeLayer) })
            }
            lassoPath = UIBezierPath()
            lassoPath?.lineWidth = 3
            lassoPath?.lineCapStyle = .round
            lassoPath?.lineJoinStyle = .round
            let dashes:[CGFloat] = [0.0, 8.0]
            lassoPath?.setLineDash(dashes, count: dashes.count, phase: 0)
            lassoPath?.move(to: touchLocation)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touchLocation = (touches.first?.location(in: self))!
        switch drawingMode {
        case .Pen:
            activePath?.addLine(to: touchLocation)
        case .Lasso:
            lassoPath?.addLine(to: touchLocation)
        }
        setNeedsDisplay()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        switch drawingMode {
        case .Pen:
            let l = CAShapeLayer()
            l.lineWidth = 3
            l.strokeColor = UIColor.black.cgColor
            l.fillColor = UIColor.clear.cgColor
            l.path = activePath?.cgPath
            layer.addSublayer(l)
        case .Lasso:
            if layer.sublayers != nil {
                for shape in layer.sublayers!
                    .map({$0 as! CAShapeLayer})
                    .filter({ (lassoPath?.bounds.intersects(($0.path?.boundingBox)!))! }) {
                    if let shapePath = shape.path {
                        let arr = extractPoints(shapePath)
                        let containsPoint = arr.filter({ (lassoPath?.contains($0))! }).first
                        if containsPoint != nil {
                            print("매칭됐네.. ", shape)
                            applyShadow(shape)
                            selectedShapes.append(shape)
                        }
                    }
                }
            }
        }
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        let c = UIGraphicsGetCurrentContext()!
        if drawingMode == .Lasso {
            c.setStrokeColor(UIColor.blue.cgColor)
            c.setFillColor(UIColor(red: 0, green: 0, blue: 1, alpha: 0.2).cgColor)
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

extension CGPoint {
}
