//
//  GraphViewController.swift
//  Calculator
//
//  Created by AmenophisIII on 7/13/15.
//  Copyright (c) 2015 AmenophisIII. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController, GraphViewDataSource {

    
    var axesOrigin : CGPoint = CGPointZero {
        didSet{
            updateUI()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem()
        navigationItem.leftItemsSupplementBackButton = true   // thanks http://nshipster.com/uisplitviewcontroller/ !
        navigationItem.title = "title1"
        println("[G] ViewDidLoad")
    }
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem()
        navigationItem.leftItemsSupplementBackButton = true
        navigationItem.title = functionToBeGraphed(graphView) ?? "nothing"
        axesOrigin = CGPointZero // if we have a geometry change, reset the center
    }

    @IBOutlet weak var graphView: GraphView! {
        didSet{
            println("[G] didSet graphView")
            graphView.dataSource = self 
            //graphView.calcDataSource is set in the prepareforsegue from the CalcVC
            // we add the gesture recognizer after the outlet has been set
            graphView.addGestureRecognizer(UIPinchGestureRecognizer(target: graphView, action: "scale:"))
            graphView.addGestureRecognizer(UIPanGestureRecognizer(target: graphView, action: "pan:"))
            let myDoubleTap = UITapGestureRecognizer(target: graphView, action: "doubleTap:")
            myDoubleTap.numberOfTapsRequired = 2
            graphView.addGestureRecognizer(myDoubleTap)
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
