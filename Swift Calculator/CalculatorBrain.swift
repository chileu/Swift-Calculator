//
//  CalculatorBrain.swift
//  Swift Calculator
//
//  Created by Chi-Ying Leung on 4/2/17.
//  Copyright © 2017 Chi-Ying Leung. All rights reserved.
//

import Foundation

struct CalculatorBrain {
    
    private var internalProgram = [OpStack]()
    
    private enum OpStack {
        case operand(Double)    // operand
        case variable(String)   // variable
        case operation(String)  // symbol
    }
    
    private var accumulator: (Double, String)?
    
    mutating func undoLast() {
        if !internalProgram.isEmpty {
            internalProgram.removeLast()
        }
    }
    
    mutating func setOperand(_ operand: Double) {
        internalProgram.append(OpStack.operand(operand))
    }
    
    
    mutating func setOperand(variable named: String) {
        internalProgram.append(OpStack.variable(named))
    }
    
    mutating func performOperation(_ symbol: String) {
        internalProgram.append(OpStack.operation(symbol))
    }
    
    private enum Operation {
        case constant(Double)
        case nullaryOperation(() -> Double, () -> String)
        case unaryOperation((Double) -> Double, (String) -> String)
        case binaryOperation((Double, Double) -> Double, (String, String) -> String)
        case equals
    }
    
    private var operations: Dictionary<String, Operation> = [
        "π" : Operation.constant(Double.pi),
        "e": Operation.constant(M_E),
        
        "rand": Operation.nullaryOperation({ Double(arc4random()) / Double(UInt32.max) }, { "rand()" }),
        
        "√" : Operation.unaryOperation(sqrt, { "√(" + $0 + ")"}),
        "cos" : Operation.unaryOperation(cos, { "cos(" + $0 + ")" }),
        "sin" : Operation.unaryOperation(sin, { "sin(" + $0 + ")" }),
        "tan" : Operation.unaryOperation(tan, { "tan(" + $0 + ")" }),
        "cos⁻¹" : Operation.unaryOperation(acos, { "cos(" + $0 + ")⁻¹" }),
        "sin⁻¹" : Operation.unaryOperation(asin, { "sin(" + $0 + ")⁻¹" }),
        "log" : Operation.unaryOperation(log10, { "log(" + $0 + ")" }),
        "ln" : Operation.unaryOperation(log, { "ln(" + $0 + ")" }),       
        "±" : Operation.unaryOperation({ -$0 }, { "-" + $0 }),
        "x⁻¹" : Operation.unaryOperation({1.0 / $0}, {"(" + $0 + ")⁻¹"}),
        "х²" : Operation.unaryOperation({$0 * $0}, { "(" + $0 + ")²"}),
        
        "%" : Operation.binaryOperation({ $0.truncatingRemainder(dividingBy: $1) }, { $0 + "%" + $1}),
        "xʸ" : Operation.binaryOperation(pow, { $0 + "^" + $1 }),
        "×" : Operation.binaryOperation({ $0 * $1 }, { $0 + "x" + $1 }),
        "÷" : Operation.binaryOperation({ $0 / $1 }, { $0 + "÷" + $1 }),
        "+" : Operation.binaryOperation({ $0 + $1 }, { $0 + "+" + $1 }),
        "−" : Operation.binaryOperation({ $0 - $1 }, { $0 + "-" + $1 }),
        
        "=" : Operation.equals,
        ]
    
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
    
    
    func evaluate(using variables: Dictionary<String, Double>? = nil) -> (result: Double?, isPending: Bool, description: String) {

        // declare internal accumulator
        var accumulator: (Double, String)?
        
        // declare PendingBinaryOperation properties and functions
        var pendingBinaryOperation: PendingBinaryOperation?
        
        func performPendingBinaryOperation() {
            if pendingBinaryOperation != nil && accumulator != nil {
                accumulator = pendingBinaryOperation?.perform(with: accumulator!)
                pendingBinaryOperation = nil
            }
        }
        
        struct PendingBinaryOperation {
            let function: (Double, Double) -> Double
            let description: (String, String) -> String
            var firstOperand: (Double, String)
            
            func perform(with secondOperand: (Double, String)) -> (Double, String) {
                return (function(firstOperand.0, secondOperand.0), description(firstOperand.1, secondOperand.1))
            }
        }
        
        // declare setOperand and performOperation functions
        func setOperand(_ operand: Double) {
            accumulator = (operand, formatter.string(from: NSNumber(value: operand))!)
        }
        
        func setOperand(variable named: String) {
            accumulator = (variables?[named] ?? 0.0, named)
        }
        
        func performOperation(_ symbol: String) {
            if let operation = operations[symbol] {
                switch operation {
                case .constant(let value):
                    accumulator = (value, symbol)
                case .nullaryOperation(let function, let description):
                    accumulator = (function(), description())
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
        
        // get vars to return
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
        
        // perform evaluation (body of 'evaluate' function)
        guard !internalProgram.isEmpty else { return (nil, false, "") }
        for op in internalProgram {
            switch op {
            case .operand(let operand):
                setOperand(operand)
            case .variable(let variable):
                setOperand(variable: variable)
            case .operation(let symbol):
                performOperation(symbol)
            }
        }
        
        return (result, resultIsPending, description ?? "")
        
    }
    
}

let formatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.maximumFractionDigits = 6
    return formatter
} ()



// deprecated:
//var resultIsPending: Bool {
//    return evaluate().isPending
//}

//var description: String? {
//    return evaluate().description
//}

//var result: Double? {
//    return evaluate().result
//}
