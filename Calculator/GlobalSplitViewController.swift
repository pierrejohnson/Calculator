//
//  GlobalSplitViewController.swift
//  Calculator
//
//  Created by AmenophisIII on 7/21/15.
//  Copyright (c) 2015 AmenophisIII. All rights reserved.
//

import UIKit

class GlobalSplitViewController: UISplitViewController, UISplitViewControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }
    
    
    // this function forces the collapse of the Detail, leaving Master on top - I Think.
    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController!, ontoPrimaryViewController primaryViewController: UIViewController!) -> Bool{
        return true
    }
    
}