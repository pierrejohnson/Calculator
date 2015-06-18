//
//  ViewController.swift
//  Calculator
//
//  Created by AmenophisIII on 3/31/15.
//  Copyright (c) 2015 AmenophisIII. All rights reserved.
//

import UIKit

class ViewController: UIViewController
{
    @IBOutlet weak var display: UILabel! // (P) '!' == "implicitely unwrapped optional"
    @IBOutlet weak var pastEqns: UILabel! // (P) eqns and past input
    @IBOutlet weak var eqDescription: UILabel! // (P) where we show the current equation
    
    var userIsInTheMiddleOfTypingSomething = false
    var brain = CalculatorBrain()
    
    
    @IBAction func appendDigit(sender: UIButton) {
        // (P)"Optional" : can only be of TWO values: NIL or ("Something")
        // (P) Note that adding '!' Unwraps the optional
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTypingSomething {
            display.text = display.text! + digit
        } else {
            display.text = digit
            userIsInTheMiddleOfTypingSomething = true
        }
    } // end appendDigit

    
    @IBAction func deleteDigit(sender: UIButton) {
        if userIsInTheMiddleOfTypingSomething {
            let predecessorIndex = display.text!.endIndex.predecessor()
            self.display.text = self.display.text?.substringToIndex(predecessorIndex)
            if display.text!.endIndex == display.text!.startIndex {
                userIsInTheMiddleOfTypingSomething = false
                displayValue = nil
            }
        }
    }
    
    // this allows us to simply set "displayValue" accross the app so we don't have to manually set display, and have to switch between string and number everytime.
    var displayValue : Double? {
        get {
                return NSNumberFormatter().numberFromString(display.text!)?.doubleValue

        }
        set {
            
            if (newValue != nil){
                display.text = "\(newValue!)" // converts a value to a string
                userIsInTheMiddleOfTypingSomething = false
            } else {
                display.text = " "
            }
        }
    }
  
    
    
    @IBAction func enter() {
        if userIsInTheMiddleOfTypingSomething == true { // prevents passing nil and crashing.
            userIsInTheMiddleOfTypingSomething = false
            if displayValue != nil{
                if let result = brain.pushOperand(displayValue!){
                    displayValue = Double(result)
                    pastEqns.text! +=  " [\(display.text!)]"
                }
            }
            eqDescription.text = brain.describeEqn() // updates eqDisplay Label
            
        }
        eqDescription.text = brain.describeEqn()

    }
    
    
    
    
    @IBAction func storeM(sender: UIButton) {
        brain.variableValues["M"] = displayValue    // we store the value
        display.text = "Stored!" // would like to havethis fade off for .3s.
        displayValue = brain.evaluate()
        pastEqns.text! +=  " [->M]"                 // for debug
        userIsInTheMiddleOfTypingSomething = false
    }
    
    
    @IBAction func recallM(sender: UIButton) {
        enter()
        displayValue = brain.variableValues["M"]
        brain.pushOperand("M")                      // returns evaluate()
        pastEqns.text! +=  " [M]"
    }
    
    
    @IBAction func operate(sender: UIButton) {
        let operation = sender.currentTitle!
        switch operation{
            
            case "±":
                let firstIndex = display.text!.startIndex
                if display.text![firstIndex] == "-"{
                    display.text!.removeAtIndex(firstIndex)
                } else {
                    display.text!.insert("-", atIndex: firstIndex)
                }
                userIsInTheMiddleOfTypingSomething = true
                return
            
            
            default:
                if userIsInTheMiddleOfTypingSomething {
                    enter()
                }
                if operation == "clr" {
                    pastEqns.text! =  " "
                    eqDescription.text! = " "
                    brain.variableValues.removeAll(keepCapacity: false)
                }
                if let result = brain.performOperation(operation){
                    displayValue = result
                    enter()
                    if (operation != "π")&&(operation != "M")
                        {pastEqns.text! +=  " [\(sender.currentTitle!)] (=) "}
                    else
                        { pastEqns.text! +=  " [\(sender.currentTitle!)] "}
                } else {
                    enter()
                    displayValue = nil
                }
                return
        }
    }
}

