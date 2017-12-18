//
//  TimetableItem.swift
//  SymondsStudentApp
//
//  Created by Søren Mortensen on 27/11/2017.
//  Copyright © 2017 Søren Mortensen, George Taylor. All rights reserved.
//

import Foundation

/// A timetable item is any entry in a student's timetable, whether it's a lesson, an exam, a trip, a study period, etc.
public struct TimetableItem: Codable, Equatable {
    
    // MARK: - Properties
    
    // MARK: User-Facing Details
    
    /// Title of the item.
    public var title: String
    
    /// Short descriptive text for the item. Often the subtitle will be blank, but for things like trips you will find
    /// that the title is `"Trip"` and the subtitle is the actual name of the trip.
    public var subtitle: String?
    
    public var type: Kind
    
    /// The date and time at which the item starts.
    public var startTime: Date
    
    public var startTimeLabel: String {
        return timeFormatter.string(from: self.startTime)
    }
    
    /// The date and time at which the item ends.
    public var endTime: Date
    
    public var endTimeLabel: String {
        return timeFormatter.string(from: self.endTime)
    }
    
    public var day: Day? {
        return Day.dayThisWeek(for: self.startTime)
    }
    
    /// Used to format strings to display the time portion of `startTime` and `endTime`.
    private let timeFormatter: DateFormatter = {
        var formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    /// The room in which the item is happening. Some items don't have rooms.
    public var room: String?
    
    /// Which teachers are running the item.
    public var staff: String?
    
    // MARK: Internal Details
    
    /// The id is normally either going to be a 14 digit integer starting "3800" or a shorter integer. It will be unique
    /// among other items of the same type.
    public let id: String
    // swiftlint:disable:previous identifier_name
    
    /// Is the item not actually a timetabled item? For instance break time, study periods and college holidays are all
    /// considered to be blank.
    public var isBlank: Bool
    
    /// Has the lesson been cancelled? If the lesson has been cancelled you should display a message to the user saying
    /// so. The value of this field will either be true or false.
    public var isCancelled: Bool
    
    /// Sometimes lessons need to switch rooms from their normal room. If this item has switched room you should display
    /// an appropriate message to make the user aware.
    public var isRoomChange: Bool
    
    // MARK: - Types
    
    /// Describes what kind of item a `TimetableItem` is.
    public enum Kind: String, Codable {
        case activity
        case artExamBooking = "artexambooking"
        case bankHoliday = "bankholiday"
        case boardingLeave = "boardingleave"
        case `break` = "break"
        case careersAppointment = "careersappointment"
        case careersWeek = "careersweek"
        case exam
        case holiday
        case lesson
        case studyPeriod = "studyperiod"
        case studySkills = "studyskills"
        case studySupport = "studysupport"
        case trip
        case tutorGroup = "tutorgroup"
    }
    
}

// MARK: - Codable

extension TimetableItem {
    
    /// :nodoc:
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.title = try container.decode(String.self, forKey: .title)
        
        let subtitle = try container.decode(String.self, forKey: .subtitle)
        self.subtitle = subtitle.isEmpty ? nil : subtitle
        
        self.type = try container.decode(Kind.self, forKey: .type)
        
        let startTimestamp = try container.decode(UInt64.self, forKey: .startTime)
        self.startTime = Date(timeIntervalSince1970: Double(startTimestamp))
        
        let endTimestamp = try container.decode(UInt64.self, forKey: .endTime)
        self.endTime = Date(timeIntervalSince1970: Double(endTimestamp))
        
        let room = try container.decode(String.self, forKey: .room)
        self.room = room.isEmpty ? nil : room
        
        let staff = try container.decode(String.self, forKey: .staff)
        self.staff = staff.isEmpty ? nil : staff
        
        self.id = try container.decode(String.self, forKey: .id)
        self.isBlank = try container.decode(Bool.self, forKey: .isBlank)
        self.isCancelled = try container.decode(Bool.self, forKey: .isCancelled)
        self.isRoomChange = try container.decode(Bool.self, forKey: .isRoomChange)
    }
    
    /// :nodoc:
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.title, forKey: .title)
        try container.encode(self.subtitle ?? "", forKey: .subtitle)
        try container.encode(self.type, forKey: .type)
        try container.encode(UInt64(self.startTime.timeIntervalSince1970), forKey: .startTime)
        try container.encode(UInt64(self.endTime.timeIntervalSince1970), forKey: .endTime)
        try container.encode(self.room ?? "", forKey: .room)
        try container.encode(self.staff ?? "", forKey: .staff)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.isBlank, forKey: .isBlank)
        try container.encode(self.isCancelled, forKey: .isCancelled)
        try container.encode(self.isRoomChange, forKey: .isRoomChange)
    }
    
    /// Coding keys for `TimetableItem`.
    private enum CodingKeys: String, CodingKey {
        case title = "Title"
        case subtitle = "Subtitle"
        case type = "Type"
        case startTime = "Start"
        case endTime = "End"
        case room = "Room"
        case staff = "Staff"
        case id = "Id" // swiftlint:disable:this identifier_name
        case isBlank = "IsBlank"
        case isCancelled = "IsCancelled"
        case isRoomChange = "IsRoomChange"
    }
    
}

// MARK: - Equatable

extension TimetableItem {
    
    /// :nodoc:
    public static func == (lhs: TimetableItem, rhs: TimetableItem) -> Bool {
        return lhs.id == rhs.id
    }

}
