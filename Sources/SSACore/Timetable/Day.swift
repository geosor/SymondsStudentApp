//
//  Day.swift
//  SSACore
//
//  Created by Søren Mortensen on 16/12/2017.
//  Copyright © 2017 Søren Mortensen, George Taylor. All rights reserved.
//

import Foundation

/// A day of the week.
///
/// This enum is fully equipped for specialised use in tracking the days of the week on which particular
/// `TimetableItem`s take place. This includes the raw values of the cases, which represent days of the week,
/// `Day.today`, which returns the day of the week at the current moment, and the methods `dateThisWeek(from:)` and
/// `dayThisWeek(for:)`, which are used for converting between `Day`s and `Date`s.
///
/// - SeeAlso: `TimetableItem`
public enum Day: Int {
    
    case monday = 0, tuesday, wednesday, thursday, friday, saturday, sunday
    
    // MARK: - Static Properties
    
    /// The day of the week for today.
    public static var today: Day {
        var weekday = calendar.component(.weekday, from: calendar.today()) - 2
        // Change Sunday to 6 instead of -1, so that the numbers (and therefore the days' raw values) reflect how many
        // days they are after the start of the week (Monday).
        if weekday == -1 { weekday += 7 }
        
        let day = Day(rawValue: weekday)!
        return day
    }
    
    /// The days of the week in an array, going from Monday to Sunday.
    public static var week: [Day] = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
    
    internal static var calendar: CalendarProtocol = Calendar.current
    
    // MARK: - Static Functions
    
    /// Calculates this week's date for a particular day of the week, going backwards if necessary.
    ///
    /// - Parameter day: The day of the week for which to calculate the date.
    /// - Returns: The date of that day of the week. Note that this is the *start of the day* on that date.
    public static func dateThisWeek(from day: Day) -> Date {
        let difference = day.rawValue - Day.today.rawValue
        return calendar.startOfDay(for: calendar.today()).addingTimeInterval(60 * 60 * 24 * TimeInterval(difference))
    }
    
    /// Returns the weekday of a date within this week. If the provided date is not within this week, returns `nil`.
    ///
    /// - Parameter date: The date to convert.
    /// - Returns: The day of the week if the provided date is within this week; otherwise, `nil`.
    public static func dayThisWeek(for date: Date) -> Day? {
        let dateToday = dateThisWeek(from: .today)
        let otherDate = calendar.startOfDay(for: date)
        
        let differenceSeconds = otherDate.timeIntervalSince(dateToday)
        let differenceDays = Int(differenceSeconds / 60 / 60 / 24)
        
        guard differenceDays >= -today.rawValue && differenceDays <= 7 - today.rawValue else {
            return nil
        }
        
        return Day(rawValue: today.rawValue + differenceDays)
    }
    
}

// MARK: - Comparable

extension Day: Comparable {
    
    /// :nodoc:
    public static func < (lhs: Day, rhs: Day) -> Bool {
        let lhsWeekday = lhs == .sunday ? lhs.rawValue + 7 : lhs.rawValue
        let rhsWeekday = rhs == .sunday ? lhs.rawValue + 7 : rhs.rawValue
        return lhsWeekday < rhsWeekday
    }
    
    /// :nodoc:
    public static func <= (lhs: Day, rhs: Day) -> Bool {
        let lhsWeekday = lhs == .sunday ? lhs.rawValue + 7 : lhs.rawValue
        let rhsWeekday = rhs == .sunday ? lhs.rawValue + 7 : rhs.rawValue
        return lhsWeekday <= rhsWeekday
    }
    
    /// :nodoc:
    public static func >= (lhs: Day, rhs: Day) -> Bool {
        let lhsWeekday = lhs == .sunday ? lhs.rawValue + 7 : lhs.rawValue
        let rhsWeekday = rhs == .sunday ? lhs.rawValue + 7 : rhs.rawValue
        return lhsWeekday >= rhsWeekday
    }
    
    /// :nodoc:
    public static func > (lhs: Day, rhs: Day) -> Bool {
        let lhsWeekday = lhs == .sunday ? lhs.rawValue + 7 : lhs.rawValue
        let rhsWeekday = rhs == .sunday ? lhs.rawValue + 7 : rhs.rawValue
        return lhsWeekday > rhsWeekday
    }
    
}
