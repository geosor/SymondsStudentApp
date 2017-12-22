//
//  DayTests.swift
//  SSACoreTests
//
//  Created by Søren Mortensen on 16/12/2017.
//  Copyright © 2017 Søren Mortensen, George Taylor. All rights reserved.
//

import XCTest
@testable import SSACore

class DayTests: XCTestCase {
    
    private var oldCalendar: CalendarProtocol!
    private let mockCalendar: CalendarProtocol = MockCalendar()
    
    override func setUp() {
        super.setUp()
        
        self.oldCalendar = Day.calendar
        Day.calendar = mockCalendar
    }
    
    override func tearDown() {
        Day.calendar = self.oldCalendar
        self.oldCalendar = nil
        
        super.tearDown()
    }
    
    func test_today() {
        XCTAssertEqual(Day.dayThisWeek(for: mockCalendar.today()), Optional(.wednesday))
    }
    
    struct MockCalendar: CalendarProtocol {
        func component(_ component: Calendar.Component, from date: Date) -> Int {
            return Calendar.current.component(component, from: date)
        }
        
        func startOfDay(for date: Date) -> Date {
            return Calendar.current.startOfDay(for: date)
        }
        
        func today() -> Date {
            return Date(timeIntervalSince1970: TimeInterval(1511970000))
        }
    }
    
}
