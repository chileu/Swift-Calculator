//
//  GraphViewController.swift
//  Swift Calculator
//
//  Created by Chi-Ying Leung on 4/13/17.
//  Copyright © 2017 Chi-Ying Leung. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController {
    
    @IBOutlet weak var graphView: GraphView! {
        didSet {
            let pinchHandler = #selector(GraphView.changeScale(byReactingTo:))
            let pinchRecognizer = UIPinchGestureRecognizer(target: graphView, action: pinchHandler)
            graphView.addGestureRecognizer(pinchRecognizer)
            
            let panHandler = #selector(GraphView.shiftOriginByPanOffset(byReactingTo:))
            let panRecognizer = UIPanGestureRecognizer(target: graphView, action: panHandler)
            graphView.addGestureRecognizer(panRecognizer)
            
            let tapHandler = #selector(GraphView.moveOriginToNewPoint(byReactingTo:))
            let tapRecognizer = UITapGestureRecognizer(target: graphView, action: tapHandler)
            graphView.addGestureRecognizer(tapRecognizer)
            
            updateUI()
        }
    }

    var yForX: ((Double) -> Double?)? {
        didSet {
            updateUI()
        }
    }
    
    func updateUI() {
        graphView?.yForX = yForX
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }


}
