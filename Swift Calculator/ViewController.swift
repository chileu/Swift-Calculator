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
        
        //sequence.text = " "
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
            sequence.text = String(newValue)
        }
    }
    
    var variableDictionary = Dictionary<String, Double>()
    var displayResult: (result: Double?, isPending: Bool, description: String) = (nil, false, "") {
        didSet {
            switch displayResult {
                case (let result, _, _): displayValue = result ?? 0
            }
            sequence.text = displayResult.description != "" ? displayResult.description + (displayResult.isPending ? " ..." : " =") : ""
        }
    }
    
    @IBAction func performOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.setOperand(displayValue)
            userIsInTheMiddleOfTyping = false
        }
        
        if let mathSymbol = sender.currentTitle {
            brain.performOperation(mathSymbol)
        }
        
        displayResult = brain.evaluate(using: variableDictionary)
    }
    
    // ->M button pressed
    @IBAction func setM(_ sender: UIButton) {
        userIsInTheMiddleOfTyping = false
        let symbol = String(sender.currentTitle!.characters.dropFirst())
        variableDictionary[symbol] = displayValue
        displayResult = brain.evaluate(using: variableDictionary)
    }
    
    // M button pressed
    @IBAction func pushM(_ sender: UIButton) {
        brain.setOperand(variable: sender.currentTitle!)
        displayResult = brain.evaluate(using: variableDictionary)
    }
    
    @IBAction func clearPressed(_ sender: UIButton) {
        // clear the UI
        displayValue = 0
        sequence.text = " "
        userIsInTheMiddleOfTyping = false
        
        // clear the Model
        brain = CalculatorBrain()
        
        // clear memory
        variableDictionary = [:]
        
    }
    
}

