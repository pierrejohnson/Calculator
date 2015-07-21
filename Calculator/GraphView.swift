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
    func calculateYForXEquals(sender: CalculatorViewController, currentX: CGFloat) ->CGFloat?
}


@IBDesignable
class GraphView: UIView {
    
    var lineWidth : CGFloat = 2 { didSet { setNeedsDisplay() }} // we set the default linewidth
    var color : UIColor = UIColor.lightGrayColor() //{ didSet { setNeedsDisplay() }}
    @IBInspectable
    var myScale : CGFloat = 10 { didSet { setNeedsDisplay() }} // we want the variables to be modifiable by others.
    var screenCenter: CGPoint {
        get {
            return convertPoint(center, fromView: superview) // converts the center
        }
    }
   
    

    // we use "weak" to make sure that the datasource pointer will not be used to keep it in memory (so the REF to itself in the controller implementation does not force it in memory)
    weak var dataSource : GraphViewDataSource? // PROTOCOL
    weak var calculatorViewDataSource: CalculatorViewDataSource?

    
    override func drawRect(rect: CGRect)
    {
        let myRect = CGRectMake(screenCenter.x-80, screenCenter.y-80, CGFloat(160),CGFloat(160)) // temp to mess with layout
        let myAxes = AxesDrawer(color: UIColor.blueColor())
        let myGraph = UIBezierPath(rect: myRect)
        myGraph.lineWidth = lineWidth
        color.set()                     // we set the color [ includes fill and stroke
        myGraph.stroke()                // we DRAW / stroke the face
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
        
        myFunctionPath.moveToPoint(CGPoint(x:widthDelta,y:viewHeight/2) )
        while widthDelta <= viewWidth
        {
            
            // our axes origin
            var origin = dataSource?.originForGraphView(self, newPoint: CGPointZero) ?? screenCenter
            
            // the value of X checked in the graph coordinate system
            var calcX =  widthDelta - origin.x
       
            var calcY = 0 // the value we want to calculate depending on the function
            
            // what we want to return to this view is the result of "evaluate" for calcX value of M.
            // i.e. we have to set a delegate that will be called in the same way as dataSoure
            
            
           // println("calcY: \(calcY) calcY: \(calcX) widthDelta = \(widthDelta) - myScale: \(myScale)")
            
            
            // calculate the function of X 
            // scale it down to the UI size / crop if NaN / does not fit
            
            myFunctionPath.addLineToPoint(CGPoint(x: widthDelta, y: viewHeight/2 ))
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
