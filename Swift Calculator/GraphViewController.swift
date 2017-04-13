//
//  GraphViewController.swift
//  Swift Calculator
//
//  Created by Chi-Ying Leung on 4/13/17.
//  Copyright © 2017 Chi-Ying Leung. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController {
    
    @IBOutlet weak var graphView: UIView!
    
    var yForX: ((Double) -> Double?)? {
        didSet {
            updateUI()
        }
    }
    
    func updateUI() {
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }



    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
