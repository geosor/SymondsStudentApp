//
//  CalendarProtocol.swift
//  SSACore
//
//  Created by Søren Mortensen on 16/12/2017.
//  Copyright © 2017 Søren Mortensen, George Taylor. All rights reserved.
//

import Foundation

/// A protocol used for mocking `Calendar`.
internal protocol CalendarProtocol {
    
    /// :nodoc:
    func component(_ component: Calendar.Component, from date: Date) -> Int
    
    /// :nodoc:
    func startOfDay(for date: Date) -> Date
    
    /// :nodoc:
    func today() -> Date
    
}
