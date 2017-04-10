//
//  ViewController.swift
//  Swift Calculator
//
//  Created by Chi-Ying Leung on 4/2/17.
//  Copyright © 2017 Chi-Ying Leung. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var sequence: UILabel!
    
    var userIsInTheMiddleOfTyping = false
    private var brain = CalculatorBrain()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sequence.text = " "
    }
    
    @IBAction func keyPressed(_ sender: UIButton) {
        let digit = sender.currentTitle!
        
        if userIsInTheMiddleOfTyping {
            guard let digitCount = display.text?.characters.count , digitCount < 17 else {
                print("digit count is too high")
                return
            }
            
            let textCurrentlyInDisplay = display.text!
            
            if digit == "." && (textCurrentlyInDisplay.range(of: ".") != nil) { return }
            if digit == "0" && textCurrentlyInDisplay == "0" { return }
            
            display.text = textCurrentlyInDisplay + digit
            
        } else {
            display.text = (digit == "." ? "0" : "") + digit
            userIsInTheMiddleOfTyping = true
        }
        
    }
    
    // this does not belong in the Model; UI related
    var displayValue: Double {
        get {
            return Double(display.text!)!
        }
        set {
            display.text = String(newValue)
        }
    }
    
    lazy var variableDictionary = [String: Double]()
    
    @IBAction func performOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.setOperand(displayValue)
            userIsInTheMiddleOfTyping = false
        }
        
        if let mathSymbol = sender.currentTitle {
            brain.performOperation(mathSymbol)
            sequence.text = brain.evaluate(using: variableDictionary).description
        }
        
        if let result = brain.evaluate(using: variableDictionary).result {
            displayValue = result
        }
    }
    
    // press "M"
    @IBAction func assignM(_ sender: UIButton) {
        brain.setOperand(variable: sender.currentTitle!)
        if let result = brain.evaluate(using: variableDictionary).result {
            displayValue = result
        }
        sequence.text = brain.evaluate(using: variableDictionary).description
    }
    
    // press "->M"
    @IBAction func setM(_ sender: UIButton) {
        let symbol = String((sender.currentTitle!).characters.dropFirst())
        variableDictionary[symbol] = displayValue
        if let result = brain.evaluate(using: variableDictionary).result {
            displayValue = result
        }
        sequence.text = brain.evaluate(using: variableDictionary).description
    }
    

    @IBAction func clearPressed(_ sender: UIButton) {
        // clear the UI
        displayValue = 0
        sequence.text = " "
        userIsInTheMiddleOfTyping = false
        
        // clear the Model
        brain = CalculatorBrain()
        
    }
    
}

