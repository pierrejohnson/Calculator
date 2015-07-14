//
//  GraphViewController.swift
//  Calculator
//
//  Created by AmenophisIII on 7/13/15.
//  Copyright (c) 2015 AmenophisIII. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
            // this is where portrait specific should be located. IF needs to be modified.... (current workaround seems ok)
        }
        navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem()
        navigationItem.leftItemsSupplementBackButton = true
        // thanks http://nshipster.com/uisplitviewcontroller/ !
    }

}
