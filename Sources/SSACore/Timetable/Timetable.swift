//
//  Timetable.swift
//  SSACore
//
//  Created by Søren Mortensen on 23/01/2018.
//  Copyright © 2018 Søren Mortensen, George Taylor. All rights reserved.
//

import Foundation

// MARK: Timetable

/// A student's timetable, consisting of a list of `Item`s plus metadata.
public struct Timetable: Codable {
    
    // MARK: Properties
    
    /// Normal items in the timetable.
    public let normalItems: [Item]
    
    public private(set) var normalItemDays: [Day]
    
    /// The clashing array is a list of items that clash with an item in the `timetable` array.
    ///
    /// Items in this array don't need to be included in a timetable grid but should be displayed to the user so that
    /// they are aware of it. Clashing items are rare, so this array is usually empty.
    public let clashingItems: [Item]
    
    public private(set) var clashingItemDays: [Day]
    
    /// The floating array is a list of timetable items (see below) that don't have a set start and end time.
    ///
    /// These are things like drop in workshops or the multigym activity. It is a lesson that the student is expected to
    /// attend once per week. You can mostly ignore the start and end times for a floating item, although the date part
    /// of the timestamp will give you the week that it occurs in.
    public let floatingItems: [Item]
    
    public private(set) var floatingItemDays: [Day]
    
    // MARK: Methods
    
    /// Returns a list of items from the specified list on the day with index `index`.
    ///
    /// This is essentially a convenience method for using `Timetable` instances with table views, which need to easily
    /// index from lists using ordinal indices rather than weekdays.
    ///
    /// - Parameters:
    ///   - list: The list to draw from.
    ///   - index: The index of the day of the week on which the desired items occur.
    public subscript(list: ItemList, index: Int) -> [Item] {
        let daysList: [Day]
        switch list {
        case .normalItems: daysList = self.normalItemDays
        case .clashingItems: daysList = self.clashingItemDays
        case .floatingItems: daysList = self.floatingItemDays
        }
        
        return self.items(from: list, on: daysList[index])
    }
    
    /// Returns the items from the specified list that occur on the specified day.
    ///
    /// - note: To check whether items exist in a list on a specific day, call `itemsOccur(in:on:)` instead of
    ///         `.isEmpty`ing the result of this method - it's faster.
    public func items(from list: ItemList, on day: Day) -> [Item] {
        let keyPath = list.keyPath
        return Timetable.items(from: self[keyPath: keyPath], on: day)
    }
    
    /// Returns the items from the given list that occur on the specified day.
    private static func items(from list: [Item], on day: Day) -> [Item] {
        return list.filter { $0.day == day }
    }
    
    /// Returns whether any items occur in the specified list on the specified day.
    public func itemsOccur(in list: ItemList, on day: Day) -> Bool {
        let keyPath = list.keyPath
        return Timetable.itemsOccur(in: self[keyPath: keyPath], on: day)
    }
    
    /// Returns whether any items occur in the given list on the specified day.
    private static func itemsOccur(in list: [Item], on day: Day) -> Bool {
        return list.contains(where: { $0.day == day })
    }
    
    /// Returns the number of days on which items occur.
    public func numberOfDaysWithItems(in list: ItemList) -> Int {
        return Day.week.filter { self.itemsOccur(in: list, on: $0) }.count
    }
    
    /// Returns the number of items that occur in the specified list on the specified day.
    public func numberOfItems(in list: ItemList, on day: Day) -> Int {
        return self.items(from: list, on: day).count
    }
    
    /// Builds a list of days on which items occur in the given list.
    ///
    /// - Note: Assumes `list` is sorted by start time.
    /// - Parameter list: A list of timetable items.
    /// - Returns: The list of days on which items occur.
    private static func buildDayList(for list: [Item]) -> [Day] {
        return Day.week.filter { itemsOccur(in: list, on: $0) }
    }
    
}

// MARK: - Timetable Extensions

// MARK: Codable

extension Timetable {
    
    /// :nodoc:
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.normalItems = try container.decode([Item].self, forKey: .normalItems)
            .sorted { $0.startTime < $1.startTime }
        
        do {
            self.clashingItems = try container.decode([Item].self, forKey: .clashingItems)
                .sorted { $0.startTime < $1.startTime }
        } catch DecodingError.typeMismatch {
            self.clashingItems = [try container.decode(Item.self, forKey: .clashingItems)]
        }
        
        do {
            self.floatingItems = try container.decode([Item].self, forKey: .floatingItems)
                .sorted { $0.startTime < $1.startTime }
        } catch DecodingError.typeMismatch {
            self.floatingItems = [try container.decode(Item.self, forKey: .floatingItems)]
        }
        
        self.normalItemDays = Timetable.buildDayList(for: self.normalItems)
        self.clashingItemDays = Timetable.buildDayList(for: self.clashingItems)
        self.floatingItemDays = Timetable.buildDayList(for: self.floatingItems)
    }
    
    /// Keys referencing each of the three lists of timetable items on `Timetable`.
    public enum ItemList: String, CodingKey {
        case normalItems = "timetable"
        case clashingItems = "clashing"
        case floatingItems = "floating"
        
        internal var keyPath: KeyPath<Timetable, [Item]> {
            switch self {
            case .normalItems: return \Timetable.normalItems
            case .clashingItems: return \Timetable.clashingItems
            case .floatingItems: return \Timetable.floatingItems
            }
        }
        
        internal static let allLists: [ItemList] = [
            .normalItems,
            .clashingItems,
            .floatingItems
        ]
    }
    
    /// Coding keys for `Codable` conformance.
    private typealias CodingKeys = ItemList
    
}

// MARK: - Item

public extension Timetable {
    
    /// A timetable item is any entry in a student's timetable, whether it's a lesson, an exam, a trip, a study period,
    /// etc.
    public struct Item: Codable, Equatable {
        
        // MARK: Properties
        
        // MARK: User-Facing Details
        
        /// Title of the item.
        public var title: String
        
        /// Short descriptive text for the item. Often the subtitle will be blank, but for things like trips you will
        /// find that the title is `"Trip"` and the subtitle is the actual name of the trip.
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
        
        /// The time range of this lesson, in the format `HH:mm-HH:mm`.
        public var timeRangeLabel: String {
            return "\(self.startTimeLabel)—\(self.endTimeLabel)"
        }
        
        /// Used to format strings to display the time portion of `startTime` and `endTime`.
        ///
        /// The format string this formatter uses is `"HH:mm"`.
        private let timeFormatter: DateFormatter = {
            var formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            return formatter
        }()
        
        /// Used to format strings to display the date portion of `startTime` and `endTime`.
        ///
        /// The format string this formatter uses is `"EEE, dd MMM yyyy"`.
        private let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE, dd MMM yyyy"
            return formatter
        }()
        
        /// The room in which the item is happening. Some items don't have rooms.
        public var room: String?
        
        /// Which teachers are running the item.
        public var staff: String?
        
        /// The date on which the lesson occurs, in string form.
        public var dateLabel: String {
            return dateFormatter.string(from: self.startTime)
        }
        
        // MARK: Internal Details
        
        /// The id is normally either going to be a 14 digit integer starting "3800" or a shorter integer. It will be
        /// unique among other items of the same type.
        public let id: String
        // swiftlint:disable:previous identifier_name
        
        /// Is the item not actually a timetabled item? For instance break time, study periods and college holidays are
        /// all considered to be blank.
        public var isBlank: Bool
        
        /// Has the lesson been cancelled? If the lesson has been cancelled you should display a message to the user
        /// saying so. The value of this field will either be true or false.
        public var isCancelled: Bool
        
        /// Sometimes lessons need to switch rooms from their normal room. If this item has switched room you should
        /// display an appropriate message to make the user aware.
        public var isRoomChange: Bool
        
        // MARK: Types
        
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
    
}

// MARK: - Item Extensions

// MARK: Codable

extension Timetable.Item {
    
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

// MARK: Equatable

extension Timetable.Item {
    
    /// :nodoc:
    public static func == (lhs: Timetable.Item, rhs: Timetable.Item) -> Bool {
        return lhs.id == rhs.id
    }
    
}

// MARK: ExampleProviding

extension Timetable.Item: ExampleProviding {
    
    /// :nodoc:
    public typealias T = Data
    // swiftlint:disable:previous type_name
    
    /// :nodoc:
    public static var example: T {
        return self.exampleString.data(using: .utf8)!
    }
    
    /// The example data in `String` form.
    private static let exampleString: String = """
        [
          {
            "Type": "lesson",
            "Id": "48000561998026",
            "Title": "A Level History (Early)",
            "Subtitle": "",
            "Start": 1511771400,
            "End": 1511774700,
            "Room": "FR103",
            "Staff": "Miss Taylor",
            "IsBlank": false,
            "IsCancelled": false,
            "IsRoomChange": false,
          },
          {
            "Type": "lesson",
            "Id": "48000562011006",
            "Title": "AS Law",
            "Subtitle": "",
            "Start": 1511774700,
            "End": 1511778000,
            "Room": "FR104",
            "Staff": "Mr James",
            "IsBlank": false,
            "IsCancelled": false,
            "IsRoomChange": false,
          },
          {
            "Type": "break",
            "Id": "",
            "Title": "Break",
            "Subtitle": "",
            "Start": 1511778000,
            "End": 1511779200,
            "Room": "",
            "Staff": "",
            "IsBlank": true,
            "IsCancelled": false,
            "IsRoomChange": false,
          },
          {
            "Type": "lesson",
            "Id": "48000562022242",
            "Title": "AS Communication & Culture",
            "Subtitle": "",
            "Start": 1511779200,
            "End": 1511782500,
            "Room": "FR105",
            "Staff": "Mrs Welsh",
            "IsBlank": false,
            "IsCancelled": false,
            "IsRoomChange": false,
          },
          {
            "Type": "lesson",
            "Id": "48000562011170",
            "Title": "A Level Psychology",
            "Subtitle": "",
            "Start": 1511782500,
            "End": 1511785800,
            "Room": "FR101",
            "Staff": "Mr Jones",
            "IsBlank": false,
            "IsCancelled": false,
            "IsRoomChange": false,
          },
          {
            "Type": "studyperiod",
            "Id": "",
            "Title": "Study Period",
            "Subtitle": "",
            "Start": 1511785800,
            "End": 1511787600,
            "Room": "",
            "Staff": "",
            "IsBlank": true,
            "IsCancelled": false,
            "IsRoomChange": false,
          },
          {
            "Type": "studyperiod",
            "Id": "",
            "Title": "Study Period",
            "Subtitle": "",
            "Start": 1511787600,
            "End": 1511790600,
            "Room": "",
            "Staff": "",
            "IsBlank": true,
            "IsCancelled": false,
            "IsRoomChange": false,
          },
          {
            "Type": "lesson",
            "Id": "48000563998448",
            "Title": "Symonds Lecture Programme (Lower Sixth)",
            "Subtitle": "",
            "Start": 1511790600,
            "End": 1511793900,
            "Room": "FR106",
            "Staff": "",
            "IsBlank": false,
            "IsCancelled": false,
            "IsRoomChange": false,
          },
          {
            "Type": "studyperiod",
            "Id": "",
            "Title": "Study Period",
            "Subtitle": "",
            "Start": 1511793900,
            "End": 1511797200,
            "Room": "",
            "Staff": "",
            "IsBlank": true,
            "IsCancelled": false,
            "IsRoomChange": false,
          },
          {
            "Type": "studyperiod",
            "Id": "",
            "Title": "Study Period",
            "Subtitle": "",
            "Start": 1511797200,
            "End": 1511800500,
            "Room": "",
            "Staff": "",
            "IsBlank": true,
            "IsCancelled": false,
            "IsRoomChange": false,
          },
          {
            "Type": "lesson",
            "Id": "48000562022242",
            "Title": "AS Communication & Culture",
            "Subtitle": "",
            "Start": 1511857800,
            "End": 1511861100,
            "Room": "FR105",
            "Staff": "Mrs Welsh",
            "IsBlank": false,
            "IsCancelled": false,
            "IsRoomChange": false,
          },
          {
            "Type": "studyperiod",
            "Id": "",
            "Title": "Study Period",
            "Subtitle": "",
            "Start": 1511861100,
            "End": 1511864400,
            "Room": "",
            "Staff": "",
            "IsBlank": true,
            "IsCancelled": false,
            "IsRoomChange": false,
          },
          {
            "Type": "break",
            "Id": "",
            "Title": "Break",
            "Subtitle": "",
            "Start": 1511864400,
            "End": 1511865600,
            "Room": "",
            "Staff": "",
            "IsBlank": true,
            "IsCancelled": false,
            "IsRoomChange": false,
          },
          {
            "Type": "lesson",
            "Id": "48000561998026",
            "Title": "A Level History (Early)",
            "Subtitle": "",
            "Start": 1511865600,
            "End": 1511868900,
            "Room": "FR103",
            "Staff": "Miss Taylor",
            "IsBlank": false,
            "IsCancelled": false,
            "IsRoomChange": false,
          },
          {
            "Type": "lesson",
            "Id": "48000562011006",
            "Title": "AS Law",
            "Subtitle": "",
            "Start": 1511868900,
            "End": 1511872200,
            "Room": "FR104",
            "Staff": "Miss French",
            "IsBlank": false,
            "IsCancelled": false,
            "IsRoomChange": false,
          },
          {
            "Type": "tutorgroup",
            "Id": "48000562087379",
            "Title": "Tutor Group",
            "Subtitle": "",
            "Start": 1511872200,
            "End": 1511874000,
            "Room": "FR107",
            "Staff": "Mr Long",
            "IsBlank": false,
            "IsCancelled": false,
            "IsRoomChange": false,
          },
          {
            "Type": "lesson",
            "Id": "48000562135505",
            "Title": "Workshop: A2 Communication & Culture",
            "Subtitle": "",
            "Start": 1511874000,
            "End": 1511877000,
            "Room": "FR105",
            "Staff": "Mrs Welsh",
            "IsBlank": false,
            "IsCancelled": false,
            "IsRoomChange": false,
          },
          {
            "Type": "studyperiod",
            "Id": "",
            "Title": "Study Period",
            "Subtitle": "",
            "Start": 1511877000,
            "End": 1511880300,
            "Room": "",
            "Staff": "",
            "IsBlank": true,
            "IsCancelled": false,
            "IsRoomChange": false,
          },
          {
            "Type": "studyperiod",
            "Id": "",
            "Title": "Study Period",
            "Subtitle": "",
            "Start": 1511880300,
            "End": 1511883600,
            "Room": "",
            "Staff": "",
            "IsBlank": true,
            "IsCancelled": false,
            "IsRoomChange": false,
          },
          {
            "Type": "studyperiod",
            "Id": "",
            "Title": "Study Period",
            "Subtitle": "",
            "Start": 1511883600,
            "End": 1511886900,
            "Room": "",
            "Staff": "",
            "IsBlank": true,
            "IsCancelled": false,
            "IsRoomChange": false,
          },
          {
            "Type": "studyperiod",
            "Id": "",
            "Title": "Study Period",
            "Subtitle": "",
            "Start": 1511944200,
            "End": 1511947500,
            "Room": "",
            "Staff": "",
            "IsBlank": true,
            "IsCancelled": false,
            "IsRoomChange": false,
          },
          {
            "Type": "studyperiod",
            "Id": "",
            "Title": "Study Period",
            "Subtitle": "",
            "Start": 1511947500,
            "End": 1511950800,
            "Room": "",
            "Staff": "",
            "IsBlank": true,
            "IsCancelled": false,
            "IsRoomChange": false,
          },
          {
            "Type": "break",
            "Id": "",
            "Title": "Break",
            "Subtitle": "",
            "Start": 1511950800,
            "End": 1511952000,
            "Room": "",
            "Staff": "",
            "IsBlank": true,
            "IsCancelled": false,
            "IsRoomChange": false,
          },
          {
            "Type": "lesson",
            "Id": "48000562011006",
            "Title": "AS Law",
            "Subtitle": "",
            "Start": 1511952000,
            "End": 1511955300,
            "Room": "FR104",
            "Staff": "Mr James",
            "IsBlank": false,
            "IsCancelled": false,
            "IsRoomChange": false,
          },
          {
            "Type": "lesson",
            "Id": "48000561998026",
            "Title": "A Level History (Early)",
            "Subtitle": "",
            "Start": 1511955300,
            "End": 1511958600,
            "Room": "FR103",
            "Staff": "Miss Taylor",
            "IsBlank": false,
            "IsCancelled": false,
            "IsRoomChange": false,
          },
          {
            "Type": "studyperiod",
            "Id": "",
            "Title": "Study Period",
            "Subtitle": "",
            "Start": 1511958600,
            "End": 1511960400,
            "Room": "",
            "Staff": "",
            "IsBlank": true,
            "IsCancelled": false,
            "IsRoomChange": false,
          },
          {
            "Type": "studyperiod",
            "Id": "",
            "Title": "Study Period",
            "Subtitle": "",
            "Start": 1511960400,
            "End": 1511963400,
            "Room": "",
            "Staff": "",
            "IsBlank": true,
            "IsCancelled": false,
            "IsRoomChange": false,
          },
          {
            "Type": "studyperiod",
            "Id": "",
            "Title": "Study Period",
            "Subtitle": "",
            "Start": 1511963400,
            "End": 1511966700,
            "Room": "",
            "Staff": "",
            "IsBlank": true,
            "IsCancelled": false,
            "IsRoomChange": false,
          },
          {
            "Type": "studyperiod",
            "Id": "",
            "Title": "Study Period",
            "Subtitle": "",
            "Start": 1511966700,
            "End": 1511970000,
            "Room": "",
            "Staff": "",
            "IsBlank": true,
            "IsCancelled": false,
            "IsRoomChange": false,
          },
          {
            "Type": "studyperiod",
            "Id": "",
            "Title": "Study Period",
            "Subtitle": "",
            "Start": 1511970000,
            "End": 1511973300,
            "Room": "",
            "Staff": "",
            "IsBlank": true,
            "IsCancelled": false,
            "IsRoomChange": false,
          },
          {
            "Type": "lesson",
            "Id": "48000562011006",
            "Title": "AS Law",
            "Subtitle": "",
            "Start": 1512030600,
            "End": 1512033900,
            "Room": "FR104",
            "Staff": "Miss French",
            "IsBlank": false,
            "IsCancelled": false,
            "IsRoomChange": false,
          },
          {
            "Type": "lesson",
            "Id": "48000562011006",
            "Title": "AS Law",
            "Subtitle": "",
            "Start": 1512033900,
            "End": 1512037200,
            "Room": "FR104",
            "Staff": "Mr James",
            "IsBlank": false,
            "IsCancelled": false,
            "IsRoomChange": false,
          },
          {
            "Type": "break",
            "Id": "",
            "Title": "Break",
            "Subtitle": "",
            "Start": 1512037200,
            "End": 1512038400,
            "Room": "",
            "Staff": "",
            "IsBlank": true,
            "IsCancelled": false,
            "IsRoomChange": false,
          },
          {
            "Type": "studyperiod",
            "Id": "",
            "Title": "Study Period",
            "Subtitle": "",
            "Start": 1512038400,
            "End": 1512041700,
            "Room": "",
            "Staff": "",
            "IsBlank": true,
            "IsCancelled": false,
            "IsRoomChange": false,
          },
          {
            "Type": "lesson",
            "Id": "48000562022242",
            "Title": "AS Communication & Culture",
            "Subtitle": "",
            "Start": 1512041700,
            "End": 1512045000,
            "Room": "FR105",
            "Staff": "Mrs Round",
            "IsBlank": false,
            "IsCancelled": false,
            "IsRoomChange": false,
          },
          {
            "Type": "studyperiod",
            "Id": "",
            "Title": "Study Period",
            "Subtitle": "",
            "Start": 1512045000,
            "End": 1512046800,
            "Room": "",
            "Staff": "",
            "IsBlank": true,
            "IsCancelled": false,
            "IsRoomChange": false,
          },
          {
            "Type": "lesson",
            "Id": "48000562135517",
            "Title": "Workshop: A2 Communication & Culture",
            "Subtitle": "",
            "Start": 1512046800,
            "End": 1512049800,
            "Room": "FR105",
            "Staff": "Mr Thompson",
            "IsBlank": false,
            "IsCancelled": false,
            "IsRoomChange": false,
          },
          {
            "Type": "lesson",
            "Id": "48000562011170",
            "Title": "A Level Psychology",
            "Subtitle": "",
            "Start": 1512049800,
            "End": 1512053100,
            "Room": "FR101",
            "Staff": "Mr Hart",
            "IsBlank": false,
            "IsCancelled": false,
            "IsRoomChange": false,
          },
          {
            "Type": "lesson",
            "Id": "48000561998026",
            "Title": "A Level History (Early)",
            "Subtitle": "",
            "Start": 1512053100,
            "End": 1512059700,
            "Room": "FR103",
            "Staff": "Miss Taylor",
            "IsBlank": false,
            "IsCancelled": false,
            "IsRoomChange": false,
          },
          {
            "Type": "lesson",
            "Id": "48000562011170",
            "Title": "A Level Psychology",
            "Subtitle": "",
            "Start": 1512117000,
            "End": 1512120300,
            "Room": "FR101",
            "Staff": "Mr Hart",
            "IsBlank": false,
            "IsCancelled": false,
            "IsRoomChange": false,
          },
          {
            "Type": "lesson",
            "Id": "48000562011170",
            "Title": "A Level Psychology",
            "Subtitle": "",
            "Start": 1512120300,
            "End": 1512123600,
            "Room": "FR101",
            "Staff": "Mr Jones, Mr Hart",
            "IsBlank": false,
            "IsCancelled": false,
            "IsRoomChange": false,
          },
          {
            "Type": "break",
            "Id": "",
            "Title": "Break",
            "Subtitle": "",
            "Start": 1512123600,
            "End": 1512124800,
            "Room": "",
            "Staff": "",
            "IsBlank": true,
            "IsCancelled": false,
            "IsRoomChange": false,
          },
          {
            "Type": "studyperiod",
            "Id": "",
            "Title": "Study Period",
            "Subtitle": "",
            "Start": 1512124800,
            "End": 1512128100,
            "Room": "",
            "Staff": "",
            "IsBlank": true,
            "IsCancelled": false,
            "IsRoomChange": false,
          },
          {
            "Type": "studyperiod",
            "Id": "",
            "Title": "Study Period",
            "Subtitle": "",
            "Start": 1512128100,
            "End": 1512131400,
            "Room": "",
            "Staff": "",
            "IsBlank": true,
            "IsCancelled": false,
            "IsRoomChange": false,
          },
          {
            "Type": "tutorgroup",
            "Id": "48000562087379",
            "Title": "Tutor Group",
            "Subtitle": "",
            "Start": 1512131400,
            "End": 1512133200,
            "Room": "FR107",
            "Staff": "Mr Long",
            "IsBlank": false,
            "IsCancelled": false,
            "IsRoomChange": false,
          },
          {
            "Type": "studyperiod",
            "Id": "",
            "Title": "Study Period",
            "Subtitle": "",
            "Start": 1512133200,
            "End": 1512136200,
            "Room": "",
            "Staff": "",
            "IsBlank": true,
            "IsCancelled": false,
            "IsRoomChange": false,
          },
          {
            "Type": "studyperiod",
            "Id": "",
            "Title": "Study Period",
            "Subtitle": "",
            "Start": 1512136200,
            "End": 1512139500,
            "Room": "",
            "Staff": "",
            "IsBlank": true,
            "IsCancelled": false,
            "IsRoomChange": false,
          },
          {
            "Type": "lesson",
            "Id": "48000562022242",
            "Title": "AS Communication & Culture",
            "Subtitle": "",
            "Start": 1512139500,
            "End": 1512146100,
            "Room": "FR105",
            "Staff": "Mrs Round",
            "IsBlank": false,
            "IsCancelled": false,
            "IsRoomChange": false,
          },
        ]
        """
    
}

// MARK: CounterexampleProviding

extension Timetable.Item: CounterexampleProviding {
    
    /// :nodoc:
    public typealias Counterexample = Data
    
    /// :nodoc:
    public static var counterexample: Counterexample {
        return self.counterexampleString.data(using: .utf8)!
    }
    
    /// The counterexample in `String` form.
    private static var counterexampleString: String = """
        {
          "boundaries": {
            "830": 1511771400,
            "925": 1511774700,
            "1020": 1511778000,
            "1040": 1511779200,
            "1135": 1511782500,
            "1230": 1511785800,
            "1300": 1511787600,
            "1350": 1511790600,
            "1445": 1511793900,
            "1540": 1511797200,
            "1635": 1511800500,
          },
          "clashing": {
            "Type": "lesson",
            "Id": "48000562011170",
            "Title": "A Level Psychology",
            "Subtitle": "",
            "Start": 1511874000,
            "End": 1511877000,
            "Room": "FR101",
            "Staff": "Mr Jones",
            "IsBlank": false,
            "IsCancelled": false,
            "IsRoomChange": false,
          },
          "floating": {
            "Type": "activity",
            "Id": "48000563948156",
            "Title": "Multigym",
            "Subtitle": "",
            "Start": 1511768700,
            "End": 1511768760,
            "Room": "FR102",
            "Staff": "Mrs Smith",
            "IsBlank": false,
            "IsCancelled": false,
            "IsRoomChange": false,
          },
          "timetable": [
            {
              "Type": "lesson",
              "Id": "48000561998026",
              "Title": "A Level History (Early)",
              "Subtitle": "",
              "Start": 1511771400,
              "End": 1511774700,
              "Room": "FR103",
              "Staff": "Miss Taylor",
              "IsBlank": false,
              "IsCancelled": false,
              "IsRoomChange": false,
            },
            {
              "Type": "lesson",
              "Id": "48000562011006",
              "Title": "AS Law",
              "Subtitle": "",
              "Start": 1511774700,
              "End": 1511778000,
              "Room": "FR104",
              "Staff": "Mr James",
              "IsBlank": false,
              "IsCancelled": false,
              "IsRoomChange": false,
            },
            {
              "Type": "break",
              "Id": "",
              "Title": "Break",
              "Subtitle": "",
              "Start": 1511778000,
              "End": 1511779200,
              "Room": "",
              "Staff": "",
              "IsBlank": true,
              "IsCancelled": false,
              "IsRoomChange": false,
            },
            {
              "Type": "lesson",
              "Id": "48000562022242",
              "Title": "AS Communication & Culture",
              "Subtitle": "",
              "Start": 1511779200,
              "End": 1511782500,
              "Room": "FR105",
              "Staff": "Mrs Welsh",
              "IsBlank": false,
              "IsCancelled": false,
              "IsRoomChange": false,
            },
            {
              "Type": "lesson",
              "Id": "48000562011170",
              "Title": "A Level Psychology",
              "Subtitle": "",
              "Start": 1511782500,
              "End": 1511785800,
              "Room": "FR101",
              "Staff": "Mr Jones",
              "IsBlank": false,
              "IsCancelled": false,
              "IsRoomChange": false,
            },
            {
              "Type": "studyperiod",
              "Id": "",
              "Title": "Study Period",
              "Subtitle": "",
              "Start": 1511785800,
              "End": 1511787600,
              "Room": "",
              "Staff": "",
              "IsBlank": true,
              "IsCancelled": false,
              "IsRoomChange": false,
            },
            {
              "Type": "studyperiod",
              "Id": "",
              "Title": "Study Period",
              "Subtitle": "",
              "Start": 1511787600,
              "End": 1511790600,
              "Room": "",
              "Staff": "",
              "IsBlank": true,
              "IsCancelled": false,
              "IsRoomChange": false,
            },
            {
              "Type": "lesson",
              "Id": "48000563998448",
              "Title": "Symonds Lecture Programme (Lower Sixth)",
              "Subtitle": "",
              "Start": 1511790600,
              "End": 1511793900,
              "Room": "FR106",
              "Staff": "",
              "IsBlank": false,
              "IsCancelled": false,
              "IsRoomChange": false,
            },
            {
              "Type": "studyperiod",
              "Id": "",
              "Title": "Study Period",
              "Subtitle": "",
              "Start": 1511793900,
              "End": 1511797200,
              "Room": "",
              "Staff": "",
              "IsBlank": true,
              "IsCancelled": false,
              "IsRoomChange": false,
            },
            {
              "Type": "studyperiod",
              "Id": "",
              "Title": "Study Period",
              "Subtitle": "",
              "Start": 1511797200,
              "End": 1511800500,
              "Room": "",
              "Staff": "",
              "IsBlank": true,
              "IsCancelled": false,
              "IsRoomChange": false,
            },
            {
              "Type": "lesson",
              "Id": "48000562022242",
              "Title": "AS Communication & Culture",
              "Subtitle": "",
              "Start": 1511857800,
              "End": 1511861100,
              "Room": "FR105",
              "Staff": "Mrs Welsh",
              "IsBlank": false,
              "IsCancelled": false,
              "IsRoomChange": false,
            },
            {
              "Type": "studyperiod",
              "Id": "",
              "Title": "Study Period",
              "Subtitle": "",
              "Start": 1511861100,
              "End": 1511864400,
              "Room": "",
              "Staff": "",
              "IsBlank": true,
              "IsCancelled": false,
              "IsRoomChange": false,
            },
            {
              "Type": "break",
              "Id": "",
              "Title": "Break",
              "Subtitle": "",
              "Start": 1511864400,
              "End": 1511865600,
              "Room": "",
              "Staff": "",
              "IsBlank": true,
              "IsCancelled": false,
              "IsRoomChange": false,
            },
            {
              "Type": "lesson",
              "Id": "48000561998026",
              "Title": "A Level History (Early)",
              "Subtitle": "",
              "Start": 1511865600,
              "End": 1511868900,
              "Room": "FR103",
              "Staff": "Miss Taylor",
              "IsBlank": false,
              "IsCancelled": false,
              "IsRoomChange": false,
            },
            {
              "Type": "lesson",
              "Id": "48000562011006",
              "Title": "AS Law",
              "Subtitle": "",
              "Start": 1511868900,
              "End": 1511872200,
              "Room": "FR104",
              "Staff": "Miss French",
              "IsBlank": false,
              "IsCancelled": false,
              "IsRoomChange": false,
            },
            {
              "Type": "tutorgroup",
              "Id": "48000562087379",
              "Title": "Tutor Group",
              "Subtitle": "",
              "Start": 1511872200,
              "End": 1511874000,
              "Room": "FR107",
              "Staff": "Mr Long",
              "IsBlank": false,
              "IsCancelled": false,
              "IsRoomChange": false,
            },
            {
              "Type": "lesson",
              "Id": "48000562135505",
              "Title": "Workshop: A2 Communication & Culture",
              "Subtitle": "",
              "Start": 1511874000,
              "End": 1511877000,
              "Room": "FR105",
              "Staff": "Mrs Welsh",
              "IsBlank": false,
              "IsCancelled": false,
              "IsRoomChange": false,
            },
            {
              "Type": "studyperiod",
              "Id": "",
              "Title": "Study Period",
              "Subtitle": "",
              "Start": 1511877000,
              "End": 1511880300,
              "Room": "",
              "Staff": "",
              "IsBlank": true,
              "IsCancelled": false,
              "IsRoomChange": false,
            },
            {
              "Type": "studyperiod",
              "Id": "",
              "Title": "Study Period",
              "Subtitle": "",
              "Start": 1511880300,
              "End": 1511883600,
              "Room": "",
              "Staff": "",
              "IsBlank": true,
              "IsCancelled": false,
              "IsRoomChange": false,
            },
            {
              "Type": "studyperiod",
              "Id": "",
              "Title": "Study Period",
              "Subtitle": "",
              "Start": 1511883600,
              "End": 1511886900,
              "Room": "",
              "Staff": "",
              "IsBlank": true,
              "IsCancelled": false,
              "IsRoomChange": false,
            },
            {
              "Type": "studyperiod",
              "Id": "",
              "Title": "Study Period",
              "Subtitle": "",
              "Start": 1511944200,
              "End": 1511947500,
              "Room": "",
              "Staff": "",
              "IsBlank": true,
              "IsCancelled": false,
              "IsRoomChange": false,
            },
            {
              "Type": "studyperiod",
              "Id": "",
              "Title": "Study Period",
              "Subtitle": "",
              "Start": 1511947500,
              "End": 1511950800,
              "Room": "",
              "Staff": "",
              "IsBlank": true,
              "IsCancelled": false,
              "IsRoomChange": false,
            },
            {
              "Type": "break",
              "Id": "",
              "Title": "Break",
              "Subtitle": "",
              "Start": 1511950800,
              "End": 1511952000,
              "Room": "",
              "Staff": "",
              "IsBlank": true,
              "IsCancelled": false,
              "IsRoomChange": false,
            },
            {
              "Type": "lesson",
              "Id": "48000562011006",
              "Title": "AS Law",
              "Subtitle": "",
              "Start": 1511952000,
              "End": 1511955300,
              "Room": "FR104",
              "Staff": "Mr James",
              "IsBlank": false,
              "IsCancelled": false,
              "IsRoomChange": false,
            },
            {
              "Type": "lesson",
              "Id": "48000561998026",
              "Title": "A Level History (Early)",
              "Subtitle": "",
              "Start": 1511955300,
              "End": 1511958600,
              "Room": "FR103",
              "Staff": "Miss Taylor",
              "IsBlank": false,
              "IsCancelled": false,
              "IsRoomChange": false,
            },
            {
              "Type": "studyperiod",
              "Id": "",
              "Title": "Study Period",
              "Subtitle": "",
              "Start": 1511958600,
              "End": 1511960400,
              "Room": "",
              "Staff": "",
              "IsBlank": true,
              "IsCancelled": false,
              "IsRoomChange": false,
            },
            {
              "Type": "studyperiod",
              "Id": "",
              "Title": "Study Period",
              "Subtitle": "",
              "Start": 1511960400,
              "End": 1511963400,
              "Room": "",
              "Staff": "",
              "IsBlank": true,
              "IsCancelled": false,
              "IsRoomChange": false,
            },
            {
              "Type": "studyperiod",
              "Id": "",
              "Title": "Study Period",
              "Subtitle": "",
              "Start": 1511963400,
              "End": 1511966700,
              "Room": "",
              "Staff": "",
              "IsBlank": true,
              "IsCancelled": false,
              "IsRoomChange": false,
            },
            {
              "Type": "studyperiod",
              "Id": "",
              "Title": "Study Period",
              "Subtitle": "",
              "Start": 1511966700,
              "End": 1511970000,
              "Room": "",
              "Staff": "",
              "IsBlank": true,
              "IsCancelled": false,
              "IsRoomChange": false,
            },
            {
              "Type": "studyperiod",
              "Id": "",
              "Title": "Study Period",
              "Subtitle": "",
              "Start": 1511970000,
              "End": 1511973300,
              "Room": "",
              "Staff": "",
              "IsBlank": true,
              "IsCancelled": false,
              "IsRoomChange": false,
            },
            {
              "Type": "lesson",
              "Id": "48000562011006",
              "Title": "AS Law",
              "Subtitle": "",
              "Start": 1512030600,
              "End": 1512033900,
              "Room": "FR104",
              "Staff": "Miss French",
              "IsBlank": false,
              "IsCancelled": false,
              "IsRoomChange": false,
            },
            {
              "Type": "lesson",
              "Id": "48000562011006",
              "Title": "AS Law",
              "Subtitle": "",
              "Start": 1512033900,
              "End": 1512037200,
              "Room": "FR104",
              "Staff": "Mr James",
              "IsBlank": false,
              "IsCancelled": false,
              "IsRoomChange": false,
            },
            {
              "Type": "break",
              "Id": "",
              "Title": "Break",
              "Subtitle": "",
              "Start": 1512037200,
              "End": 1512038400,
              "Room": "",
              "Staff": "",
              "IsBlank": true,
              "IsCancelled": false,
              "IsRoomChange": false,
            },
            {
              "Type": "studyperiod",
              "Id": "",
              "Title": "Study Period",
              "Subtitle": "",
              "Start": 1512038400,
              "End": 1512041700,
              "Room": "",
              "Staff": "",
              "IsBlank": true,
              "IsCancelled": false,
              "IsRoomChange": false,
            },
            {
              "Type": "lesson",
              "Id": "48000562022242",
              "Title": "AS Communication & Culture",
              "Subtitle": "",
              "Start": 1512041700,
              "End": 1512045000,
              "Room": "FR105",
              "Staff": "Mrs Round",
              "IsBlank": false,
              "IsCancelled": false,
              "IsRoomChange": false,
            },
            {
              "Type": "studyperiod",
              "Id": "",
              "Title": "Study Period",
              "Subtitle": "",
              "Start": 1512045000,
              "End": 1512046800,
              "Room": "",
              "Staff": "",
              "IsBlank": true,
              "IsCancelled": false,
              "IsRoomChange": false,
            },
            {
              "Type": "lesson",
              "Id": "48000562135517",
              "Title": "Workshop: A2 Communication & Culture",
              "Subtitle": "",
              "Start": 1512046800,
              "End": 1512049800,
              "Room": "FR105",
              "Staff": "Mr Thompson",
              "IsBlank": false,
              "IsCancelled": false,
              "IsRoomChange": false,
            },
            {
              "Type": "lesson",
              "Id": "48000562011170",
              "Title": "A Level Psychology",
              "Subtitle": "",
              "Start": 1512049800,
              "End": 1512053100,
              "Room": "FR101",
              "Staff": "Mr Hart",
              "IsBlank": false,
              "IsCancelled": false,
              "IsRoomChange": false,
            },
            {
              "Type": "lesson",
              "Id": "48000561998026",
              "Title": "A Level History (Early)",
              "Subtitle": "",
              "Start": 1512053100,
              "End": 1512059700,
              "Room": "FR103",
              "Staff": "Miss Taylor",
              "IsBlank": false,
              "IsCancelled": false,
              "IsRoomChange": false,
            },
            {
              "Type": "lesson",
              "Id": "48000562011170",
              "Title": "A Level Psychology",
              "Subtitle": "",
              "Start": 1512117000,
              "End": 1512120300,
              "Room": "FR101",
              "Staff": "Mr Hart",
              "IsBlank": false,
              "IsCancelled": false,
              "IsRoomChange": false,
            },
            {
              "Type": "lesson",
              "Id": "48000562011170",
              "Title": "A Level Psychology",
              "Subtitle": "",
              "Start": 1512120300,
              "End": 1512123600,
              "Room": "FR101",
              "Staff": "Mr Jones, Mr Hart",
              "IsBlank": false,
              "IsCancelled": false,
              "IsRoomChange": false,
            },
            {
              "Type": "break",
              "Id": "",
              "Title": "Break",
              "Subtitle": "",
              "Start": 1512123600,
              "End": 1512124800,
              "Room": "",
              "Staff": "",
              "IsBlank": true,
              "IsCancelled": false,
              "IsRoomChange": false,
            },
            {
              "Type": "studyperiod",
              "Id": "",
              "Title": "Study Period",
              "Subtitle": "",
              "Start": 1512124800,
              "End": 1512128100,
              "Room": "",
              "Staff": "",
              "IsBlank": true,
              "IsCancelled": false,
              "IsRoomChange": false,
            },
            {
              "Type": "studyperiod",
              "Id": "",
              "Title": "Study Period",
              "Subtitle": "",
              "Start": 1512128100,
              "End": 1512131400,
              "Room": "",
              "Staff": "",
              "IsBlank": true,
              "IsCancelled": false,
              "IsRoomChange": false,
            },
            {
              "Type": "tutorgroup",
              "Id": "48000562087379",
              "Title": "Tutor Group",
              "Subtitle": "",
              "Start": 1512131400,
              "End": 1512133200,
              "Room": "FR107",
              "Staff": "Mr Long",
              "IsBlank": false,
              "IsCancelled": false,
              "IsRoomChange": false,
            },
            {
              "Type": "studyperiod",
              "Id": "",
              "Title": "Study Period",
              "Subtitle": "",
              "Start": 1512133200,
              "End": 1512136200,
              "Room": "",
              "Staff": "",
              "IsBlank": true,
              "IsCancelled": false,
              "IsRoomChange": false,
            },
            {
              "Type": "studyperiod",
              "Id": "",
              "Title": "Study Period",
              "Subtitle": "",
              "Start": 1512136200,
              "End": 1512139500,
              "Room": "",
              "Staff": "",
              "IsBlank": true,
              "IsCancelled": false,
              "IsRoomChange": false,
            },
            {
              "Type": "lesson",
              "Id": "48000562022242",
              "Title": "AS Communication & Culture",
              "Subtitle": "",
              "Start": 1512139500,
              "End": 1512146100,
              "Room": "FR105",
              "Staff": "Mrs Round",
              "IsBlank": false,
              "IsCancelled": false,
              "IsRoomChange": false,
            },
          ],
        },
        """
    
}

// MARK: - FriendItem

extension Timetable {
    
    /// An item that belongs to one of the primary user's friends, containing limited details to protect their privacy.
    public struct FriendItem {
        
        /// The ID of the item.
        public let id: String
        
        /// The start time of the item.
        public let start: Date
        
        /// The end time of the item.
        public let end: Date
        
        /// Creates a new instance of `FriendItem`.
        ///
        /// - Parameters:
        ///   - id: The item's ID.
        ///   - start: The item's start time.
        ///   - end: The item's end time.
        public init(id: String, start: Date, end: Date) {
            self.id = id
            self.start = start
            self.end = end
        }
        
    }
    
}
