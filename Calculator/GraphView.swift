//
//  GraphView.swift
//  Calculator
//
//  Created by AmenophisIII on 7/14/15.
//  Copyright (c) 2015 AmenophisIII. All rights reserved.
//

import UIKit

class GraphView: UIView {

    
    // we want the variables to be modifiable by others. 
    
    var lineWidth : CGFloat = 3 { didSet { setNeedsDisplay() }} // we set the default linewidth
    var color : UIColor = UIColor.blueColor() { didSet { setNeedsDisplay() }}


    var screenCenter: CGPoint {
        get {
            return convertPoint(center, fromView: superview) // converts the center
        }
    }

    
    
    override func drawRect(rect: CGRect)
    {

        let myRect = CGRectMake(screenCenter.x, screenCenter.y, CGFloat(10),CGFloat(10)) // temp to mess with layout
        let myGraph = UIBezierPath(rect: myRect)
        
        myGraph.lineWidth = lineWidth
        color.set()                     // we set the color [ includes fill and stroke
        myGraph.stroke()                // we DRAW / stroke the face
    
    }


}
