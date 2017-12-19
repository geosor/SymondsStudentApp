//
//  NotificationController.swift
//  WatchExtension
//
//  Created by Søren Mortensen on 18/12/2017.
//  Copyright © 2017 Søren Mortensen, George Taylor. All rights reserved.
//

import WatchKit
import Foundation
import UserNotifications

class NotificationController: WKUserNotificationInterfaceController {
    
    // MARK: - WKUserNotificationInterfaceController
    
    /// :nodoc:
    override init() {
        // Initialize variables here.
        super.init()
        
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
    
    /// :nodoc:
    override func didReceive(_ notification: UNNotification,
                             withCompletion completion: @escaping (WKUserNotificationInterfaceType) -> Swift.Void) {
        // This method is called when a notification needs to be presented.
        // Implement it if you use a dynamic notification interface.
        // Populate your dynamic notification interface as quickly as possible.
        //
        // After populating your dynamic notification interface call the completion block.
        completion(.custom)
    }
    
}
