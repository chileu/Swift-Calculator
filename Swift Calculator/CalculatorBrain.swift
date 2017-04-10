//
//  CalculatorBrain.swift
//  Swift Calculator
//
//  Created by Chi-Ying Leung on 4/2/17.
//  Copyright © 2017 Chi-Ying Leung. All rights reserved.
//

import Foundation

struct CalculatorBrain {
    
    private enum OpStack {
        case operand(Double)    // operand
        case variable(String)   // variable
        case operation(String)  // operation symbol
    }
    
    private var internalProgram = [OpStack]()
    
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
        "х²" : Operation.unaryOperation({ $0 * $0 }, { "(" + $0 + ")" + "²"}),
        "x⁻¹" : Operation.unaryOperation({ 1.0/$0 }, { "(" + $0 + ")" + "⁻¹"}),
        
        "%" : Operation.binaryOperation({ $0.truncatingRemainder(dividingBy: $1) }, { $0 + "%" + $1}),
        "xʸ" : Operation.binaryOperation({ pow($0, $1) }, { $0 + "^" + $1 }),

        "×" : Operation.binaryOperation({ $0 * $1 }, { $0 + "x" + $1 }),
        "÷" : Operation.binaryOperation({ $0 / $1 }, { $0 + "÷" + $1 }),
        "+" : Operation.binaryOperation({ $0 + $1 }, { $0 + "+" + $1 }),
        "−" : Operation.binaryOperation({ $0 - $1 }, { $0 + "-" + $1 }),
        
        "=" : Operation.equals,
        ]
    
    func evaluate(using variables: Dictionary<String, Double>? = nil) -> (result: Double?, resultIsPending: Bool, description: String) {
        
        var cache: (accumulator: Double?, description: String?)
        
        var pendingBinaryOperation: PendingBinaryOperation?
        
        struct PendingBinaryOperation {
            let function: (Double, Double) -> Double
            let description: (String, String) -> String
            var firstOperand: Double
            var firstOperandDescription: String
            
            func performFunction(with secondOperand: Double) -> Double {
                return (function(firstOperand, secondOperand))
            }
            
            func performDescriptionFunction(with secondOperand: String) -> String {
                return (description(firstOperandDescription, secondOperand))
            }
        }
        
        func performPendingBinaryOperation() {
            if pendingBinaryOperation != nil && cache.accumulator != nil {
                cache.accumulator = pendingBinaryOperation!.performFunction(with: cache.accumulator!)
                cache.description = pendingBinaryOperation!.performDescriptionFunction(with: cache.description!)
                pendingBinaryOperation = nil
            }
        }
        
        var result: Double? {
            return cache.accumulator
        }
        
        var resultIsPending: Bool {
            return pendingBinaryOperation != nil
        }
        
        var description: String? {
            get {
                if pendingBinaryOperation != nil {
                    return pendingBinaryOperation!.description(pendingBinaryOperation!.firstOperandDescription, cache.description ?? "")
                } else {
                    return cache.description
                }
            }
        }
        
        func setOperand(_ operand: Double) {
            cache.accumulator = operand
            cache.description = String(format: "%g", cache.accumulator!)
        }
        
        func setOperand(variable named: String) {
            cache.accumulator = variables?[named] ?? 0.0
            cache.description = named
        }
        
        func performOperation(_ symbol: String) {
            if let operation = operations[symbol] {
                switch operation {
                case .constant(let value):
                    cache = (value, symbol)
                case .unaryOperation(let function, let descriptionFunction):
                    if cache.accumulator != nil {
                        cache.accumulator = function(cache.accumulator!)
                    }
                    if cache.description != nil {
                        cache.description = descriptionFunction(cache.description!)
                    }
                case .binaryOperation(let function, let descriptionFunction):
                    performPendingBinaryOperation()
                    if cache.accumulator != nil {
                        pendingBinaryOperation = PendingBinaryOperation(function: function, description: descriptionFunction, firstOperand: cache.accumulator!, firstOperandDescription: cache.description!)
                        cache.accumulator = nil
                        cache.description = nil
                    }
                case .equals:
                    performPendingBinaryOperation()
                }
            }
        }
        
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
