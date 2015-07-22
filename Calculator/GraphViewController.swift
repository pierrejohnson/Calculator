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
     
            println("[GVC]GraphViewController: \(self)") // Calculator.GraphViewController
            println("[GVC]self.splitViewController: \(self.splitViewController)")
            println("[GVC]self.splitViewController.viewControllers: \(self.splitViewController?.viewControllers)")
            println("[GVC]self.splitViewController.viewControllers.count: \(self.splitViewController?.viewControllers.count)")
//
//        if let vc = splitViewController?.viewControllers {
//            println(vc)
//            println(vc.count)
//            if let fst = vc.first {
//                println(fst.subviews)         // returns nil
//            //  println(fst.subviews.first)   // segfaults
//            }
//        }
        //it seems the SplitViewController is set but not the views themselves -
     //   graphView.calcDataSource = splitViewController?.viewControllers.first
       // graphView.calcDataSource = splitViewController?.viewControllers.first as CalculatorViewController
        
        
    }
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        axesOrigin = CGPointZero // if we have a geometry change, reset the center
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
