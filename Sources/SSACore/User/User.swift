//
//  User.swift
//  SSACore
//
//  Created by Søren Mortensen on 10/01/2018.
//  Copyright © 2018 Søren Mortensen, George Taylor. All rights reserved.
//

import Foundation

// MARK: User

/// A user of the SymondsTimetable app.
///
/// This could represent the primary user, a friend, or a user listing. This relationship is reflected through
/// conformance to `User`.
///
/// - SeeAlso: `AuthenticatedUser`
public protocol User {
    
    // MARK: Properties
    
    /// The user's ID number.
    var id: Int { get }
    
    /// The user's college username.
    var username: String { get }
    
    /// The user's Symonds email.
    var email: String { get }
    
    /// The user's forename.
    var forename: String { get }
    
    /// The user's surname.
    var surname: String { get }
    
    /// The user's full name.
    var name: String { get }
    
}

// MARK: Default Implementations

/// Default implementations for the `User` protocol.
public extension User {
    
    /// :nodoc:
    public var name: String {
        return "\(forename) \(surname)"
    }
    
}

// MARK: - AuthenticatedUser

/// A `User` that is able to authenticate with the PSC data service.
///
/// - Note: `AuthenticatedUser` requires that the implementing type be a `class` because `UserAuthenticator` needs to be
///         able to refer to it by reference.
/// - SeeAlso: `UserAuthenticator`
public protocol AuthenticatedUser: class, User {
    
    // MARK: Properties
    
    /// The authenticator that was used to log in and construct this user.
    var authenticator: UserAuthenticator { get }
    
    // MARK: Initialisers
    
    /// Creates a new instance from user details and with a reference to the authenticator used to log this user in.
    ///
    /// - Parameters:
    ///   - userDetails: Details of the user.
    ///   - authenticator: The authenticator that was used to log in and construct this user.
    init(userDetails: UserService.UserDetails, authenticator: UserAuthenticator)
    
}
