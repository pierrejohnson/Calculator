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
}

// we need to be able to defer to what calculates our values
protocol CalculatorViewDataSource: class {
    // func is passing itself around - so we have a reference
    func calculateYForXEquals (sender: GraphView, currentX: CGFloat) ->CGFloat?
}


@IBDesignable
class GraphView: UIView {
    
    var lineWidth : CGFloat = 2 { didSet { setNeedsDisplay() }} // we set the default linewidth
    var color : UIColor = UIColor.lightGrayColor() //{ didSet { setNeedsDisplay() }}
    @IBInspectable
    var myScale : CGFloat = 1 { didSet { setNeedsDisplay() }} // we want the variables to be modifiable by others - Note: Seems Storyboard has priority on this.
    var screenCenter: CGPoint {
        get {
            return convertPoint(center, fromView: superview) // converts the center
        }
    }
   
    

    // we use "weak" to make sure that the datasource pointer will not be used to keep it in memory (so the REF to itself in the controller implementation does not force it in memory)
    weak var dataSource : GraphViewDataSource? // PROTOCOL
    weak var calcDataSource: CalculatorViewDataSource?

    
    override func drawRect(rect: CGRect)
    {
        let myAxes = AxesDrawer(color: UIColor.blueColor())
        color.set()                     // we set the color
        // this call returns the offset origin  - or the screenCenter
        let graphOrigin = dataSource?.originForGraphView(self, newPoint: CGPointZero) ?? screenCenter
        myAxes.drawAxesInRect(frame, origin: graphOrigin, pointsPerUnit: myScale) // pointsPerUnit allows for granularity/scale (Bigger = zoom)
        drawMyFunction()
    }

    
  
    func drawMyFunction (){
        
        
        let myFunctionPath = UIBezierPath()
        myFunctionPath.lineWidth = lineWidth
        color = UIColor.redColor()
        color.set()
        // (1) establish bounds - we are drawing left to right, but we should figure out how many pixels that is
        let viewWidth = self.bounds.width // I am not sure this is the PIXEL width
        // (2) establish the number of pixels in the frame
        let viewHeight = self.bounds.height
        var widthDelta : CGFloat = 0
        var origin = dataSource?.originForGraphView(self, newPoint: CGPointZero) ?? screenCenter         // our axes origin
        var currentlyDrawing = false
        // creating the original point
        
        
        while widthDelta <= viewWidth
        {
            var calcX =  (widthDelta - origin.x)/myScale
            var calcY = calcDataSource?.calculateYForXEquals(self, currentX: calcX) // the value we want to calculate 

            
            if calcY != nil {
                var transposedY = origin.y - (calcY! * myScale)
                // stop drawing if we are out of frame
                if transposedY < CGFloat(0) || transposedY >  viewHeight { currentlyDrawing = false }
                

                if currentlyDrawing && !calcY!.isInfinite && currentlyDrawing{
                    myFunctionPath.addLineToPoint(CGPoint(x: widthDelta, y: transposedY ))
                    
                } else {
                    myFunctionPath.moveToPoint(CGPoint(x:widthDelta,y: transposedY) )
                    currentlyDrawing = true
                }
            } else {
                currentlyDrawing = false
            }
            
            
            
            
            
            widthDelta++
        }
        myFunctionPath.stroke()
        color = UIColor.darkGrayColor()
        color.set()
        }
    
    
    
    // GESTURE: scale handler - scales graph as pinched
    func scale (gesture: UIPinchGestureRecognizer){
        if gesture.state == .Changed{
            myScale *= gesture.scale
            gesture.scale = 1
        }
    }
    
    // GESTURE: pan handler - moves the graph as panned
    func pan (gesture: UIPanGestureRecognizer){
        switch gesture.state{
        case .Ended: fallthrough
        case .Changed:
            let translation = gesture.translationInView(self)
            if translation != CGPointZero{
                dataSource?.originForGraphView(self, newPoint: translation)
            }
             gesture.setTranslation(CGPointZero, inView: self) // we need this so that the gesture RESETS itself as it keeps updating the axesCenter via delegate
        default:
            break
        }
    }
    
    // GESTURE: doubleTap handler - centers the display on doubletap location
    func doubleTap (gesture: UITapGestureRecognizer){
        var translation = screenCenter
        translation.x = screenCenter.x - gesture.locationInView(self).x
        translation.y = screenCenter.y - gesture.locationInView(self).y
        dataSource?.originForGraphView(self, newPoint: translation)
        setNeedsDisplay()
    }
    
}
