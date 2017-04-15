//
//  GraphView.swift
//  Swift Calculator
//
//  Created by Chi-Ying Leung on 4/13/17.
//  Copyright © 2017 Chi-Ying Leung. All rights reserved.
//

import UIKit

@IBDesignable
class GraphView: UIView {
    
    var axes: AxesDrawer?
    var yForX: ((Double) -> Double?)?
    
    var originRelativeToCenter = CGPoint.zero { didSet { setNeedsDisplay() } }
    
    private var graphCenter: CGPoint {
        return convert(center, from: superview)
    }
    
    private var origin: CGPoint {
        get {
            var origin = originRelativeToCenter
            origin.x += graphCenter.x
            origin.y += graphCenter.y
            return origin
        }
        set {
            var origin = newValue
            origin.x -= graphCenter.x
            origin.y -= graphCenter.y
            originRelativeToCenter = origin
        }
    }
    
    @IBInspectable
    var scale: CGFloat = 50 { didSet { setNeedsDisplay() } }
    @IBInspectable
    var axesColor: UIColor = UIColor.blue
    @IBInspectable
    var graphColor: UIColor = UIColor.purple
    @IBInspectable
    var lineWidth: CGFloat = 2.0
    
    func moveOriginToNewPoint(byReactingTo tapRecognizer: UITapGestureRecognizer) {
        tapRecognizer.numberOfTapsRequired = 2
        switch tapRecognizer.state {
        case .changed: fallthrough
        case .ended:
            origin.x = tapRecognizer.location(in: self).x
            origin.y = tapRecognizer.location(in: self).y
        default:
            break
        }
    }
    
    func shiftOriginByPanOffset(byReactingTo panRecognizer: UIPanGestureRecognizer) {
        switch panRecognizer.state {
        case .changed: fallthrough
        case .ended:
            let translation = panRecognizer.translation(in: self)
            if translation != CGPoint.zero {
                origin.x += translation.x
                origin.y += translation.y
                panRecognizer.setTranslation(CGPoint.zero, in: self)
            }
        default:
            break
        }
    }
    
    func changeScale(byReactingTo pinchRecognizer: UIPinchGestureRecognizer) {
        switch pinchRecognizer.state {
        case .changed, .ended:
            scale *= pinchRecognizer.scale
            pinchRecognizer.scale = 1
        default:
            break
        }
    }
    
    override func draw(_ rect: CGRect) {
        axes = AxesDrawer(color: axesColor, contentScaleFactor: contentScaleFactor)
        axes?.drawAxes(in: bounds, origin: origin, pointsPerUnit: scale)
        graphColor.set()
        pathForOperation(yForX).stroke()
    }
    
    private func pathForOperation(_ yForX: ((Double) -> Double?)?) -> UIBezierPath {
        let path = UIBezierPath()
        let unitsOnXAxis = Double(bounds.size.width / scale)
        let originOffset = Double(originRelativeToCenter.x / scale)
        let pixelIncrementor = 1 / Double(scale * contentScaleFactor)
        
        var currentPoint: CGPoint? = nil
        for x in stride(from: -(unitsOnXAxis / 2) - originOffset, through: (unitsOnXAxis / 2) - originOffset, by: pixelIncrementor) {
            if yForX != nil, let y = yForX!(x) {
                let nextPoint = CGPoint(x: origin.x + (CGFloat(x) * scale), y: origin.y - (CGFloat(y) * scale))
                
                if currentPoint != nil {
                    path.move(to: CGPoint(x: currentPoint!.x, y: currentPoint!.y))
                    path.addLine(to: nextPoint)
                    currentPoint = nextPoint
                } else {
                    currentPoint = nextPoint
                }
            }
        }
        path.lineWidth = lineWidth
        return path
    }


}
