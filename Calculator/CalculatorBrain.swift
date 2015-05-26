//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by AmenophisIII on 4/9/15.
//  Copyright (c) 2015 AmenophisIII. All rights reserved.
//

import Foundation           // (P) note that there are no UI imports, this is just the base stuff


class CalculatorBrain
{
    
    // Swift has a cool feature where you can associate data with types/classes
    // TYPES are FUNCTIONS IN SWIFT
    private enum Op : Printable // the "Printable" is a PROTOCOL.
    {
        case Operand(Double)
        case UnaryOperation(String, Double -> Double)    //(P) the 2nd argument is a FUNCTION TYPE
        case BinaryOperation(String, (Double, Double) -> Double)
        case PiOperation (String)
        case StoreOperation (String) // ?
        case RecallOperation (String) // ?
        case ClrOperation(String)
        case SignOperation(String)
        
        var description: String {
            get {
                switch self{
                case .Operand(let operand):
                    return "\(operand)"
                case .UnaryOperation(let symbol,_):
                    return symbol
                case .BinaryOperation(let symbol, _):
                    return symbol
                case .PiOperation (let symbol):
                    return symbol
                case .ClrOperation (let symbol):
                    return symbol
                case .SignOperation(let symbol):
                    return symbol
                case .RecallOperation(let symbol): // ?
                    return symbol
                case .StoreOperation(let symbol):  // ?
                    return symbol
                }
            }
        }
    }

   private var opStack = [Op]()           //(P) the '=' works as an initializer in the declaration
   private var knownOps = [String:Op]()   //(P) note that this is the same as : var knownOps = Dictionary<String,Op>()i
    private var variableValues = [String:Double]()  //(P) this is our new structure to store the variables that we put in there. it is populated as we are declaring it - syntictacly
    
    init(){
        
        func learnOp (op : Op) {
            knownOps[op.description] = op
        }
        
        learnOp(Op.BinaryOperation("×", *))
        learnOp(Op.BinaryOperation("÷") {$1 / $0})
        learnOp(Op.BinaryOperation("+", +))
        learnOp(Op.BinaryOperation("−") {$1 - $0})
        learnOp(Op.UnaryOperation("√", sqrt))
        learnOp(Op.UnaryOperation("sin", sin))
        learnOp(Op.UnaryOperation("cos", cos))
        learnOp(Op.PiOperation("π"))
        learnOp(Op.ClrOperation("clr"))
        learnOp(Op.SignOperation("±"))
        learnOp(Op.StoreOperation("↪︎M"))
        learnOp(Op.RecallOperation("M"))
    }

    private func evaluate(ops :[Op]) -> (result: Double?, remainingOps: [Op]) {
        
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            
            switch op{
            
                case .Operand(let operand):
                    return (operand, remainingOps)
              
                case .UnaryOperation(_, let operation):
                    let operandEvaluation = evaluate(remainingOps)
                    if let operand = operandEvaluation.result{
                        return (operation(operand), operandEvaluation.remainingOps)
                    }
        
                case .BinaryOperation(_, let operation):
                    let op1Evaluation = evaluate (remainingOps)
                    if let operand = op1Evaluation.result {
                        let op2Evaluation = evaluate (op1Evaluation.remainingOps)
                        if let operand2 = op2Evaluation.result {
                            return (operation(operand, operand2), op2Evaluation.remainingOps)
                        }
                    }
                
                case .PiOperation(let pi):
                    return (M_PI, remainingOps)
                
                case .ClrOperation(let clr):
                    remainingOps.removeAll(keepCapacity: false)
                    return (0.0, remainingOps)
    
                case .SignOperation(let sign):
                    return (0.0, remainingOps)
                
                case .StoreOperation(let varStore):
                    // this is where we want to store the variable that was just passed - we need to get it from the display!
                    return (0.0, remainingOps)
                
                case .RecallOperation(let varRecall):
                    // this is where we call back the stored variable previously set by the user
                    return (0.0, remainingOps)
            }
    
        }
        return (nil , ops)
    }
    
    func evaluate() -> Double? {
        let (result, remainder ) = evaluate(opStack) // (P) diff version of calling
        println( "\(opStack) = \(result) with \(remainder) left over")
        return result
    }
    
    func pushOperand(operand: Double) ->Double? {
        opStack.append(Op.Operand(operand))
        return evaluate()
    }
    
    // (P) we return the value stored for set symbol else we return nil
    func pushOperand(symbol : String) -> Double? {
        if let content = variableValues[symbol]{
            return content
        }
        return nil
    }
    
    func performOperation(symbol: String) ->Double?{
        if let operation = knownOps[symbol] {      //(P) this is how you look something up in a dictionary -  note that the type is an OPTIONAL OP
            opStack.append(operation)
            if operation.description == "clr"{
                opStack.removeAll(keepCapacity: false)
            }
        }
        return evaluate()
    }
}