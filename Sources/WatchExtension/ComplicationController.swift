//
//  ComplicationController.swift
//  WatchExtension
//
//  Created by Søren Mortensen on 18/12/2017.
//  Copyright © 2017 Søren Mortensen, George Taylor. All rights reserved.
//

import ClockKit

class ComplicationController: NSObject, CLKComplicationDataSource {
    
    // MARK: - CLKComplicationDataSource
    
    // MARK: Timeline Configuration
    
    /// :nodoc:
    func getSupportedTimeTravelDirections(
        for complication: CLKComplication,
        withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void
    ) {
        handler([.forward, .backward])
    }
    
    /// :nodoc:
    func getTimelineStartDate(for complication: CLKComplication,
                              withHandler handler: @escaping (Date?) -> Void) {
        handler(nil)
    }
    
    /// :nodoc:
    func getTimelineEndDate(for complication: CLKComplication,
                            withHandler handler: @escaping (Date?) -> Void) {
        handler(nil)
    }
    
    /// :nodoc:
    func getPrivacyBehavior(for complication: CLKComplication,
                            withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.showOnLockScreen)
    }
    
    // MARK: Timeline Population
    
    /// :nodoc:
    func getCurrentTimelineEntry(for complication: CLKComplication,
                                 withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        // Call the handler with the current timeline entry
        handler(nil)
    }
    
    /// :nodoc:
    func getTimelineEntries(for complication: CLKComplication,
                            before date: Date,
                            limit: Int,
                            withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        // Call the handler with the timeline entries prior to the given date
        handler(nil)
    }
    
    /// :nodoc:
    func getTimelineEntries(for complication: CLKComplication,
                            after date: Date,
                            limit: Int,
                            withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        // Call the handler with the timeline entries after to the given date
        handler(nil)
    }
    
    // MARK: Placeholder Templates
    
    /// :nodoc:
    func getLocalizableSampleTemplate(for complication: CLKComplication,
                                      withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        // This method will be called once per supported complication, and the results will be cached
        handler(nil)
    }
    
}
