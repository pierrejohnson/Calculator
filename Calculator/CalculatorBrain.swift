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
        case Variable(String) // ?
        case UnaryOperation(String, Double -> Double)    //(P) the 2nd argument is a FUNCTION TYPE
        case BinaryOperation(String, (Double, Double) -> Double)
        case PiOperation (String)
        case ClrOperation(String)
        case SignOperation(String)
        
        var description: String {
            get {
                switch self{
                case .Operand(let operand):
                    return "\(operand)"
                case .Variable(let symbol):     // ?
                    return symbol
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

                }
            }
        }
    }

    private var opStack = [Op]()           //(P) the '=' works as an initializer in the declaration
    private var knownOps = [String:Op]()   //(P) note that this is the same as : var knownOps = Dictionary<String,Op>()i
    var variableValues = [String:Double]()  //(P) this is our new structure to store the variables that we put in there. it is populated as we are declaring it - syntacticly
    
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
        learnOp(Op.Variable("M"))
    }

    private func evaluate(ops :[Op]) -> (result: Double?, remainingOps: [Op]) {
        
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            
            switch op{
            
                case .Operand(let operand):
                    return (operand, remainingOps)
                case .Variable(let symbol):
                    if (variableValues[symbol] != nil){
                        return (variableValues[symbol], remainingOps)
                    }else{
                        return (nil, remainingOps)  // neturns nil if the var has not been set
                }
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
    
    // pushes the new variable onto our stack then returns evaluate()
    func pushOperand(symbol : String) -> Double? {
        opStack.append(Op.Variable(symbol))
        return evaluate()
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
    
    
    func describeEqn()-> String? {
        var result = ""
        let sortedString = stackToString(result, ops: opStack)
        
        return sortedString.resultingString
    }
    
    
    
    
// stackToString takes our stack and recursively produces the string that examplifies the result
    private func stackToString(resultString: String, ops: [Op]) -> (resultingString: String?, remainingOps: [Op]) {
        
        if !ops.isEmpty {
            var remainingOps = ops
            var tempString = resultString
            let op = remainingOps.removeLast()
            
            switch op{
            case .Operand(let operand):
                tempString += operand.description
                return (tempString, remainingOps)
                
            case .Variable(let symbol):
                if (variableValues[symbol] != nil){
                    tempString += symbol
                    return ( tempString, remainingOps)
                }else{
                    return ("?", remainingOps)  // returns nil if the var has not been set
                }
                
            case .UnaryOperation(let symbol, _):
                tempString += symbol + "(" + stackToString(tempString, ops: remainingOps).resultingString! + ")"
                return (tempString, remainingOps)
                
            case .BinaryOperation(let symbol, _):
                tempString += "(" + stackToString(  stackToString(tempString, ops: stackToString(tempString, ops: remainingOps).remainingOps).resultingString! + symbol , ops: remainingOps).resultingString! + ")"
                return (tempString, remainingOps)
                

            default:
                return ("default", remainingOps)
            
            }
            
        }
        return (nil , ops)
    }
    
    
}