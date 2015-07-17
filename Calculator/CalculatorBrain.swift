//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by AmenophisIII on 4/9/15.
//  Copyright (c) 2015 AmenophisIII. All rights reserved.
//

import Foundation                                       // note that there are no UI imports, this is just the base stuff


class CalculatorBrain
{
    
    // Swift has a cool feature where you can associate data with types/classes
    // TYPES are FUNCTIONS IN SWIFT
    private enum Op : Printable                         // the "Printable" is a PROTOCOL that enables the description
    {
        case Operand(Double)
        case Variable(String)
        case UnaryOperation(String, Double -> Double)   // 2nd arg is a fn() that tks a dbl and rtn a dbl
        case BinaryOperation(String, (Double, Double) -> Double)
        case PiOperation (String)
        case ClrOperation(String)
        case SignOperation(String)
        
        var description: String {
            get {
                switch self{
                case .Operand(let operand):
                    return "\(operand)"
                case .Variable(let symbol):
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
        
        var precedence: String {            // used to minimize parentheses
            switch self{
            case .BinaryOperation(let symbol, _):
                if symbol == "+" || symbol == "−"{
                    return "addsub"
                }
                return "multdiv"
            case .UnaryOperation (let symbol):
                return "unary"
                
            default:
                return "none"
            }
        }
        
    }

    private var opStack = [Op]()            // '=' works as an initializer in the declaration
    private var knownOps = [String:Op]()    //  same as   knownOps = Dictionary<String,Op>()
    var variableValues = [String:Double]()  // variable dicitionary
    
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

    
    typealias PropertyList = AnyObject // this is to properly document stuff
    
    var program : PropertyList {
        
        get {
            return opStack.map { $0.description }
        }
        set {
            if let opSymbols = newValue as? Array<String> {
                var newOpStack = [Op]()
                for opSymbol in opSymbols {
                    if let op = knownOps[opSymbol] {
                        newOpStack.append(op)
                    } else if let operand = NSNumberFormatter().numberFromString(opSymbol)?.doubleValue {
                        newOpStack.append(.Operand(operand))
                    }
                }
                opStack = newOpStack
            }
        }
        
        
        
        
    }
    
    
    private func evaluate(ops :[Op]) -> (result: Double?, remainingOps: [Op]) {
        
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            
            switch op{
                case .Operand(let operand):
                    return (operand, remainingOps)
                case .Variable(let symbol):
                    if (variableValues[symbol] != nil) {
                        return (variableValues[symbol], remainingOps)
                    }
                    return (nil, remainingOps)
                case .UnaryOperation(_, let operation):
                    let operandEvaluation = evaluate(remainingOps)
                    if let operand = operandEvaluation.result {
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
                    return (nil, remainingOps)
                case .SignOperation(let sign):
                    return (nil, remainingOps)
            }
        }
        return (nil , ops)
    }
    
    func evaluate() -> Double? {
        let (result, remainder) = evaluate(opStack)
        return result
    }

    func evaluateAndReportErrors() -> (result: Double?, error: String?) {
        let (result, remainder, error) = evaluateAndReportErrors(opStack)
        return (result, error)
    }

    // == evaluate + error string
    private func evaluateAndReportErrors(ops :[Op]) -> (result: Double?, remainingOps: [Op], error: String?) {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            
            switch op{
            case .Operand(let operand):
                return (operand, remainingOps, nil)
            case .Variable(let symbol):
                if (variableValues[symbol] != nil){
                    return (variableValues[symbol], remainingOps, nil)
                }
                return (nil, remainingOps, "var \(symbol) not set")
            case .UnaryOperation(_, let operation):
                let operandEvaluation = evaluateAndReportErrors(remainingOps)
                if let operand = operandEvaluation.result{
                    if (op.description == "√") && (operand <= 0.0){
                        return (operation(operand), operandEvaluation.remainingOps, "sqr(neg #)!")
                    }
                    return (operation(operand), operandEvaluation.remainingOps, nil)
                }
                return (nil, operandEvaluation.remainingOps, "Op error")
            case .BinaryOperation(_, let operation):
                let op1Evaluation = evaluateAndReportErrors (remainingOps)
                if let operand = op1Evaluation.result {
                    if (op.description == "÷") && (operand == 0.0){
                        return (nil, op1Evaluation.remainingOps, "Error: dividing by Zero!")
                    }
                    let op2Evaluation = evaluateAndReportErrors (op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result {
                        return (operation(operand, operand2), op2Evaluation.remainingOps, nil)
                    }else{
                        return (nil, op2Evaluation.remainingOps, "Op2 error")
                    }
                }
                return (nil, op1Evaluation.remainingOps, "Op1 error")
            case .PiOperation(let pi):
                return (M_PI, remainingOps, nil)
            case .ClrOperation(let clr):
                remainingOps.removeAll(keepCapacity: false)
                return (nil, remainingOps, nil)
            case .SignOperation(let sign):
                return (nil, remainingOps, nil)
            }
        }
        return (nil , ops, " ")
    }
    
    func pushOperand(operand: Double) -> (result: Double?, error: String?) {
        opStack.append(Op.Operand(operand))
        return evaluateAndReportErrors()
    }

    // pushes a variable onto our stack then returns evaluate()
    func pushOperand(symbol : String) -> (result: Double?, error: String?) {
        opStack.append(Op.Variable(symbol))
        return evaluateAndReportErrors()
    }

    // Undo button
    func popOperand() -> (result:Double?, error: String?){
        if !opStack.isEmpty{
            opStack.removeLast()
        }
        return evaluateAndReportErrors()
    }
    
    func performOperation(symbol: String) -> (result:Double?, error: String?) {

        if let operation = knownOps[symbol] {
            opStack.append(operation)
            if operation.description == "clr"{
                opStack.removeAll(keepCapacity: false)
            }
        }
        return evaluateAndReportErrors()
    }

    func describeEqn()-> String? {
        var sortedString  = stackToString(opStack, precedence: "none")
        var cleanedOutput = cleanMyOutput(sortedString.resultingString)
        var previousEqn   = ""
        
        while (sortedString.remainingOps.count > 0) {
                sortedString  = stackToString(sortedString.remainingOps, precedence: "none")
                previousEqn   = cleanMyOutput(sortedString.resultingString)
                previousEqn  += ", " + cleanedOutput
                cleanedOutput = previousEqn
        }
        if opStack.last?.precedence == "addsub" || opStack.last?.precedence == "multdiv" || opStack.last?.precedence == "unary" {
            cleanedOutput += " ="
        }
        return cleanedOutput
    }
    
    // cleans the output
    private func cleanMyOutput(inputString:String?) -> String {
        if inputString != nil{
            var outputString = cleanDotZero(inputString!)
            return outputString
        }
        return " "
    }
    
    private func cleanDotZero(inputString:String) -> String {
        var outputString = inputString
        var iterator = outputString.startIndex
        while (iterator != outputString.endIndex){
            
            if outputString[iterator] == "."{
                iterator = iterator.successor()
                if outputString[iterator] == "0"{
                    iterator = iterator.successor()
                    if iterator == outputString.endIndex {
                        iterator=iterator.predecessor()
                    }
                    switch outputString[iterator]{
                    case "1","2","3","4","5","6","7","8","9":
                        break
                    case "0":
                        if iterator.successor() == outputString.endIndex {
                            iterator = iterator.predecessor().predecessor()
                            outputString.removeAtIndex(iterator.successor())
                            outputString.removeAtIndex(iterator.successor())
                            break
                        }
                        break
                    default:
                        iterator = iterator.predecessor().predecessor().predecessor()
                        outputString.removeAtIndex(iterator.successor())
                        outputString.removeAtIndex(iterator.successor())
                        break
                    }
                }
            }
            iterator = iterator.successor()
        }
        return outputString
    }

    // recursively produces the string that describes current equation
    private func stackToString(ops: [Op],  precedence : String) -> (resultingString: String?, remainingOps: [Op]) {
        
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            var lastOperation = precedence
            
            switch op{
            case .Operand(let operand):
                if operand.description[operand.description.startIndex] == "-" {
                    return ("(" + operand.description + ")", remainingOps)
                }else{
                    return (operand.description, remainingOps)
                }
            case .Variable(let symbol):
                if (variableValues[symbol] != nil){
                    return ( symbol, remainingOps)
                }else{
                    return ("m", remainingOps)  // debug
                }
                
            case .UnaryOperation(let symbol, _):
                let op1conv = stackToString(remainingOps, precedence: "unary")
                if let op1 = op1conv.resultingString {
                    return (symbol + "(" + op1 + ")", stackToString(remainingOps, precedence: "unary").remainingOps)
                }else{
                    return (symbol + "(?)", stackToString(remainingOps, precedence: "unary").remainingOps)
                }
                
            case .BinaryOperation(let symbol, _):
                
                let op1conv = stackToString(remainingOps, precedence: op.precedence)
                if let op1 = op1conv.resultingString {
                    let op2conv = stackToString(op1conv.remainingOps, precedence: op.precedence)
                    if let op2 = op2conv.resultingString {
                        // if the nested op has previous operation of the same type, we skip adding parenthesis.
                        if  (lastOperation == "addsub" && op.precedence == "multdiv") || (lastOperation == "multdiv" && op.precedence == "addsub"){
                            return ("(" + op2 + symbol + op1 + ")", op2conv.remainingOps)
                        }else{
                            return (op2 + symbol + op1, op2conv.remainingOps)
                        }
                        
                    }else{
                        return ("(" + op1 + symbol +  "?)", op2conv.remainingOps) // I think we should return nothing
                    }
                }else{
                    return ("(?" + symbol + "?)", stackToString(remainingOps, precedence: lastOperation).remainingOps) // I think we should return nothing
                }
            case .PiOperation(let pi):
                return (op.description, remainingOps)
                
            default:
                return ("default", remainingOps)
            
            }
            
        }
        return (nil, ops)
    }
    
    
}