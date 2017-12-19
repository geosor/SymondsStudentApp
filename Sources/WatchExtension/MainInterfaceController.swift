//
//  MainInterfaceController.swift
//  WatchExtension
//
//  Created by Søren Mortensen on 18/12/2017.
//  Copyright © 2017 Søren Mortensen, George Taylor. All rights reserved.
//

import WatchKit
import Foundation

class MainInterfaceController: WKInterfaceController {
    
    // MARK: - WKInterfaceController
    
    /// :nodoc:
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }
    
    /// :nodoc:
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    /// :nodoc:
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
}
