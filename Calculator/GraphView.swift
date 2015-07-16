//
//  GraphView.swift
//  Calculator
//
//  Created by AmenophisIII on 7/14/15.
//  Copyright (c) 2015 AmenophisIII. All rights reserved.
//

import UIKit



protocol GraphViewDataSource : class {
    // the only purpose is to get the data - so we call it DataSource
    func originForGraphView (sender: GraphView, newPoint: CGPoint) -> CGPoint?
    // func is passing itself around - so we have a reference
}





@IBDesignable
class GraphView: UIView {

    
    // we want the variables to be modifiable by others. 
    
    var lineWidth : CGFloat = 2 { didSet { setNeedsDisplay() }} // we set the default linewidth
    var color : UIColor = UIColor.lightGrayColor() { didSet { setNeedsDisplay() }}
    @IBInspectable
    var myScale : CGFloat = 10 { didSet { setNeedsDisplay() }}

    var screenCenter: CGPoint {
        get {
            return convertPoint(center, fromView: superview) // converts the center
        }
    }

    // we need to use "weak" to make sure that the datasource pointer will not be used to keep it in memory (so the REF to itself in the controller implementation does not force it in memory)
    weak var dataSource : GraphViewDataSource? // PROTOCOL
    
    
    
    
    
    override func drawRect(rect: CGRect)
    {

        let myRect = CGRectMake(screenCenter.x-80, screenCenter.y-80, CGFloat(160),CGFloat(160)) // temp to mess with layout
        let myAxes = AxesDrawer(color: UIColor.darkGrayColor())
        
        let myGraph = UIBezierPath(rect: myRect)
        
        myGraph.lineWidth = lineWidth
        color.set()                     // we set the color [ includes fill and stroke
        myGraph.stroke()                // we DRAW / stroke the face
        
        
        // this call returns the offset origin  - or the screenCenter
        let graphOrigin = dataSource?.originForGraphView(self, newPoint: CGPointZero) ?? screenCenter
        myAxes.drawAxesInRect(frame, origin: graphOrigin, pointsPerUnit: myScale) // pointsPerUnit allows for granularity/scale (Bigger = zoom)
    }

    //scale handler
    func scale (gesture: UIPinchGestureRecognizer){
        if gesture.state == .Changed{
            myScale *= gesture.scale
            gesture.scale = 1
        }
    }
    
    
    
    
    
    
    // pan handler
    func pan (gesture: UIPanGestureRecognizer){
        
        // do we want the CENTER of the screen to be the affected transform? 
        // does it even make a diff?
       var newOffset: CGPoint = screenCenter
        switch gesture.state{
        case .Ended: fallthrough
        case .Changed:
            let translation = gesture.translationInView(self)
            
            newOffset.x += translation.x
            newOffset.y += translation.y
            if translation != CGPointZero{
                dataSource?.originForGraphView(self, newPoint: newOffset)
            }
            // if the next line is active it keeps trying to redraw itself to center... Unsure why.
            // seems like newOffset is reset to screenCenter before we have had a chance to redraw
            // and because the SLIGHT translation & Slight diff value we toggle between center & ONE changed location...
            // it's late, it's mostly working, I'm going to nap.
            
            // gesture.setTranslation(CGPointZero, inView: self)
        
        default:
            break
        }

    }
    
}
