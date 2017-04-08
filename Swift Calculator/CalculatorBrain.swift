//
//  CalculatorBrain.swift
//  Swift Calculator
//
//  Created by Chi-Ying Leung on 4/2/17.
//  Copyright © 2017 Chi-Ying Leung. All rights reserved.
//

import Foundation

struct CalculatorBrain {
    
    private var accumulator: (Double, String)?
    
    var resultIsPending: Bool {
        return pendingBinaryOperation != nil
    }
    
    var description: String? {
        if resultIsPending {
            return pendingBinaryOperation!.description(pendingBinaryOperation!.firstOperand.1, accumulator?.1 ?? "")
        } else {
            return accumulator?.1
        }
    }
    
    var result: Double? {
        if accumulator != nil {
            return accumulator!.0
        } else {
            return nil
        }
    }
    
    private enum Operation {
        case constant(Double)
        case unaryOperation((Double) -> Double, (String) -> String)
        case binaryOperation((Double, Double) -> Double, (String, String) -> String)
        case equals
    }
    
    private var operations: Dictionary<String, Operation> = [
        "π" : Operation.constant(Double.pi),
        "e": Operation.constant(M_E),
        
        "√" : Operation.unaryOperation({ sqrt($0) }, { "√(" + $0 + ")"}),
        "cos" : Operation.unaryOperation({ cos($0) }, { "cos(" + $0 + ")" }),
        "sin" : Operation.unaryOperation({ sin($0) }, { "sin(" + $0 + ")" }),
        "log" : Operation.unaryOperation({ log10($0) }, { "log(" + $0 + ")" }),
        "±" : Operation.unaryOperation({ -$0 }, { "-" + $0 }),
        
        "%" : Operation.binaryOperation({ $0.truncatingRemainder(dividingBy: $1) }, { $0 + "%" + $1}),
        "x^y" : Operation.binaryOperation({ pow($0, $1) }, { $0 + "^" + $1 }),
        "×" : Operation.binaryOperation({ $0 * $1 }, { $0 + "x" + $1 }),
        "÷" : Operation.binaryOperation({ $0 / $1 }, { $0 + "÷" + $1 }),
        "+" : Operation.binaryOperation({ $0 + $1 }, { $0 + "+" + $1 }),
        "−" : Operation.binaryOperation({ $0 - $1 }, { $0 + "-" + $1 }),
        
        "=" : Operation.equals,
        ]
    
    mutating func performOperation(_ symbol: String) {
        if let operation = operations[symbol] {
            switch operation {
            case .constant(let value):
                accumulator = (value, symbol)
            case .unaryOperation(let function, let description):
                if accumulator != nil {
                    accumulator = (function(accumulator!.0), description(accumulator!.1))
                }
            case .binaryOperation(let function, let description):
                if accumulator != nil {
                    performPendingBinaryOperation()
                    pendingBinaryOperation = PendingBinaryOperation(function: function, description: description, firstOperand: accumulator!)
                    accumulator = nil
                }
            case .equals:
                performPendingBinaryOperation()
            }
            
        }
        
    }
    
    mutating private func performPendingBinaryOperation() {
        if pendingBinaryOperation != nil && accumulator != nil {
            accumulator = pendingBinaryOperation?.perform(with: accumulator!)
            pendingBinaryOperation = nil
        }
    }
    
    private var pendingBinaryOperation: PendingBinaryOperation?
    
    private struct PendingBinaryOperation {
        let function: (Double, Double) -> Double
        let description: (String, String) -> String
        var firstOperand: (Double, String)
        
        func perform(with secondOperand: (Double, String)) -> (Double, String) {
            return (function(firstOperand.0, secondOperand.0), description(firstOperand.1, secondOperand.1))
        }
    }
    
    mutating func setOperand(_ operand: Double) {
        accumulator = (operand, String(format: "%g", operand))
    }
    
}
