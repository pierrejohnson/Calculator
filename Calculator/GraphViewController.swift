//
//  GraphViewController.swift
//  Calculator
//
//  Created by AmenophisIII on 7/13/15.
//  Copyright (c) 2015 AmenophisIII. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController, GraphViewDataSource {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
            // this is where portrait specific should be located. IF needs to be modified.... (current workaround seems ok)
        }
        navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem()
        navigationItem.leftItemsSupplementBackButton = true   // thanks http://nshipster.com/uisplitviewcontroller/ !
    }
    
    
   override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        // if we had a geometry change, reset the center
        axesOrigin = CGPointZero
    }
    
    
    
    
    @IBOutlet weak var graphView: GraphView! {
        didSet{
            graphView.dataSource = self
            // we add the gesture recognizer after the outlet has been set
            graphView.addGestureRecognizer(UIPinchGestureRecognizer(target: graphView, action: "scale:"))
            graphView.addGestureRecognizer(UIPanGestureRecognizer(target: graphView, action: "pan:"))
            
            let myDoubleTap = UITapGestureRecognizer(target: graphView, action: "doubleTap:")
            myDoubleTap.numberOfTapsRequired = 2
            graphView.addGestureRecognizer(myDoubleTap)
            updateUI()
        }

    }
  
    // axes origin is originally set to zero - it gets modified via the delegate & forces a redraw every time
    var axesOrigin : CGPoint = CGPointZero {
        didSet{
            updateUI()
        }
    }

    

    

    
    // how we update the UI
    private func updateUI(){
        graphView.setNeedsDisplay()
    }
    
    
    
    // The delegate function - if graph has been offset / moved, it forces a redraw.
    func originForGraphView (sender: GraphView, newPoint: CGPoint) -> CGPoint? {
       
        if axesOrigin == CGPointZero{
            axesOrigin = graphView.screenCenter
        }
        axesOrigin.x += newPoint.x
        axesOrigin.y += newPoint.y
        return axesOrigin
    }
    
    
    func functionToBeGraphed(sender: GraphView) -> String? {
            // maybe it could return the arguments currently set in the OpStack.... but we still need to access the opstack
        
        return nil
    }
    
    
}
