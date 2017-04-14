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
    
    var boundsCenter: CGPoint {
        return CGPoint(x: bounds.midX, y: bounds.midY)
    }
    
    @IBInspectable
    var pointsPerUnit: CGFloat = 50
    @IBInspectable
    var axesColor: UIColor = UIColor.blue
    @IBInspectable
    var graphColor: UIColor = UIColor.purple
    @IBInspectable
    var lineWidth: CGFloat = 2.0
    
    override func draw(_ rect: CGRect) {
        axes = AxesDrawer(color: axesColor, contentScaleFactor: contentScaleFactor)
        axes?.drawAxes(in: bounds, origin: boundsCenter, pointsPerUnit: pointsPerUnit)
        graphColor.set()
        pathForOperation(yForX).stroke()
    }
    
    private func pathForOperation(_ yForX: ((Double) -> Double?)?) -> UIBezierPath {
        let path = UIBezierPath()
        let unitsOnXAxis = Double(bounds.size.width / pointsPerUnit)
        let pixelIncrementor = 1 / Double(pointsPerUnit * contentScaleFactor)
        
        var origin: CGPoint? = nil
        for x in stride(from: -(unitsOnXAxis / 2), through: (unitsOnXAxis / 2), by: pixelIncrementor) {
            if yForX != nil, let y = yForX!(x) {
                let nextCoordinatePoint = CGPoint(x: boundsCenter.x + (CGFloat(x) * pointsPerUnit), y: boundsCenter.y - (CGFloat(y) * pointsPerUnit))
                
                if origin != nil {
                    path.move(to: CGPoint(x: origin!.x, y: origin!.y))
                    path.addLine(to: nextCoordinatePoint)
                    origin = nextCoordinatePoint
                } else {
                    origin = nextCoordinatePoint
                }
            }
        }
        path.lineWidth = lineWidth
        return path
    }


}
