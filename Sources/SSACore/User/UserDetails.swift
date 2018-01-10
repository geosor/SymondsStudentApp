//
//  UserDetails.swift
//  SSACore
//
//  Created by Søren Mortensen on 10/01/2018.
//  Copyright © 2018 Søren Mortensen, George Taylor. All rights reserved.
//

import Foundation

/// Details about a user, as received from the data service.
public struct UserDetails: Codable {
    
    /// The user's ID number.
    public let id: Int
    
    /// The user's college username.
    public let username: String
    
    /// The user's Symonds email.
    public let email: String
    
    /// The user's forename.
    public let forename: String
    
    /// The user's surname.
    public let surname: String
    
    /// The user's full name.
    public let name: String
    
}

// MARK: - Codable

extension UserDetails {
    
    private enum CodingKeys: String, CodingKey {
        case id = "Id"
        case username = "Username"
        case email = "Email"
        case forename = "Forename"
        case surname = "Surname"
        case name = "Name"
    }
    
}
