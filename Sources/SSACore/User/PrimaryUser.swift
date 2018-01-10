//
//  PrimaryUser.swift
//  SSACore
//
//  Created by Søren Mortensen on 10/01/2018.
//  Copyright © 2018 Søren Mortensen, George Taylor. All rights reserved.
//

import Foundation

/// The user of the app.
public final class PrimaryUser: AuthenticatedUser {
    
    // MARK: - Properties
    
    // MARK: - User
    
    public var id: Int
    
    public var forename: String
    
    public var surname: String
    
    public var username: String
    
    public var name: String
    
    // MARK: - AuthenticatedUser
    
    public var authenticator: UserAuthenticator
    
    public var email: String
    
    public init(userDetails: UserDetails, authenticator: UserAuthenticator) {
        self.authenticator = authenticator
        
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
            userDetails.name
        )
    }
    
}
