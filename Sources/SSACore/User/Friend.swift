//
//  Friend.swift
//  SSACore
//
//  Created by Søren Mortensen on 24/01/2018.
//  Copyright © 2018 Søren Mortensen, George Taylor. All rights reserved.
//

import Foundation

/// Represents another user who is a friend of the primary user.
public struct Friend: User {
    
    // MARK: - Properties
    
    /// The user's timetable items. These objects contain only the id, start time, and end time of the items.
    public let items: [Timetable.FriendItem]
    
    // MARK: - Initialisers
    
    /// Creates a new instance of `Friend`.
    ///
    /// - Parameters:
    ///   - userDetails: The friend's details.
    ///   - items: The friend's items.
    public init(userDetails: UserService.UserDetails, items: [Timetable.FriendItem]) {
        (self.id,
         self.username,
         self.email,
         self.forename,
         self.surname,
         self.name) = (
            userDetails.id,
            userDetails.username,
            userDetails.email,
            userDetails.forename,
            userDetails.surname,
            userDetails.name)
        
        self.items = items
    }
    
    // MARK: - User
    
    /// :nodoc:
    public var id: Int
    
    /// :nodoc:
    public let username: String
    
    /// :nodoc:
    public var email: String
    
    /// :nodoc:
    public let forename: String
    
    /// :nodoc:
    public let surname: String
    
    /// :nodoc:
    public let name: String
    
}
