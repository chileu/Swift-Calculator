//
//  CalculatorBrain.swift
//  Swift Calculator
//
//  Created by Chi-Ying Leung on 4/2/17.
//  Copyright © 2017 Chi-Ying Leung. All rights reserved.
//

import Foundation

struct CalculatorBrain {
    
    private var accumulator: Double?
    private var lastDescription: String?
    lazy var resultIsPending = false
    lazy var description = String()
    
    var result: Double? {
        get {
            return accumulator
        }
    }
    
    // enum is a data structure with discrete values
    // optional is an enum too. in set state, has associated value. in not set state, does not have associated value.
    private enum Operation {
        case constant(Double)
        case unaryOperation((Double) -> Double)
        case binaryOperation((Double, Double) -> Double)
        case equals
    }
    
    private var operations: Dictionary<String, Operation> = [
        "π" : Operation.constant(Double.pi),
        "e": Operation.constant(M_E),
        "√" : Operation.unaryOperation(sqrt),
        "cos" : Operation.unaryOperation(cos),
        "sin" : Operation.unaryOperation(sin),
        "log" : Operation.unaryOperation(log10),
        "±" : Operation.unaryOperation({ -$0 }),
        "%" : Operation.binaryOperation({ $0.truncatingRemainder(dividingBy: $1) }),
        "x^y" : Operation.binaryOperation({ pow($0, $1) }),
        "×" : Operation.binaryOperation({ $0 * $1 }),
        "÷" : Operation.binaryOperation({ $0 / $1 }),
        "+" : Operation.binaryOperation({ $0 + $1 }),
        "−" : Operation.binaryOperation({ $0 - $1 }),
        "=" : Operation.equals,
        ]
    
    mutating func performOperation(_ symbol: String) {
        if let operation = operations[symbol] {
            switch operation {
            case .constant(let value):
                accumulator = value
                description = description + symbol
            case .unaryOperation(let function):
                if accumulator != nil {
                    let formattedAccumulator = String(format: "%g", accumulator!)
                    if let lastDescription = lastDescription {
                        description = lastDescription + symbol + "(\(formattedAccumulator))"
                        resultIsPending = false
                        accumulator = function(accumulator!)
                    }
                }
            case .binaryOperation(let function):
                if accumulator != nil {
                    performPendingBinaryOperation()
                    pendingBinaryOperation = PendingBinaryOperation(function: function, firstOperand: accumulator!)
                    description += symbol
                    resultIsPending = true
                    accumulator = nil
                }
            case .equals:
                performPendingBinaryOperation()
                resultIsPending = false
                pendingBinaryOperation = nil
            }
            
        }
        
    }
    
    mutating private func performPendingBinaryOperation() {
        if pendingBinaryOperation != nil && accumulator != nil {
            accumulator = pendingBinaryOperation?.perform(with: accumulator!)
        }
    }
    
    private var pendingBinaryOperation: PendingBinaryOperation?
    
    private struct PendingBinaryOperation {
        let function: (Double, Double) -> Double
        var firstOperand: Double
        
        func perform(with secondOperand: Double) -> Double {
            return function(firstOperand, secondOperand)
        }
    }
    
    mutating func setOperand(_ operand: Double) {
        accumulator = operand
        lastDescription = description
        description = description + String(format: "%g", operand)
    }
    
    mutating func clearHistory() {
        accumulator = nil
        resultIsPending = false
        description = " "
        lastDescription = nil
        pendingBinaryOperation = nil
    }
    
}
