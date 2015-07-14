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


    
    // what are our locations?
    
    // CALCULATED center of the screen: CGPoint { get { return convertPoint(center, fromView: superview)} }
    var screenCenter: CGPoint { get { return convertPoint( center, fromView: superview)} }
    
    
    
    
    
    override func drawRect(rect: CGRect)
    {

        let myRect = CGRectMake(screenCenter.x, screenCenter.y, CGFloat(50),CGFloat(50))

        let myGraph = UIBezierPath(rect: myRect)
        
        myGraph.lineWidth = lineWidth
        color.set()                     // we set the color [ includes fill and stroke
        myGraph.stroke()                // we DRAW / stroke the face
    
    }


}
