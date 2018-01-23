//
//  UserService.swift
//  SSACore
//
//  Created by Søren Mortensen on 18/01/2018.
//  Copyright © 2018 Søren Mortensen, George Taylor. All rights reserved.
//

import Foundation

/// Service that provides user details.
public final class UserService {
    
    // MARK: - Properties
    
    /// An access token, used for authentication with the user service.
    private let accessToken: LoginService.AccessToken
    
    // MARK: - Methods
    
    /// Makes a request to the API to return user information.
    ///
    /// - Parameter completion: A completion handler to run to handle the result of the request.
    public func makeRequest(completion: @escaping (DataService.Result<UserDetails>) -> Void) {
        DataService(accessToken: self.accessToken)
            .call(.user, parameters: [:], completion: completion)
    }
    
    // MARK: - Initialisers
    
    /// Initialises an instance of `UserService` with an access token.
    ///
    /// - Parameter accessToken: The access token, used for authentication with the user service.
    public init(accessToken: LoginService.AccessToken) {
        self.accessToken = accessToken
    }
    
    // MARK: - Types
    
    /// Details about a user, as received from the data service.
    public struct UserDetails: Decodable {
        
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
        
        // MARK: Decodable
        
        public init(from decoder: Decoder) throws {
            let sampleContainer = try decoder.container(keyedBy: SampleCodingKeys.self)
            
            let id = try sampleContainer.decode(Int.self, forKey: .id)
            guard id != 0 else {
                self.id = 0
                self.username = "testuser"
                self.email = "testuser@example.com"
                self.forename = "Test"
                self.surname = "User"
                self.name = "Test User"
                return
            }
            
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            self.id = try container.decode(Int.self, forKey: .id)
            self.username = try container.decode(String.self, forKey: .username)
            self.email = try container.decode(String.self, forKey: .email)
            self.forename = try container.decode(String.self, forKey: .forename)
            self.surname = try container.decode(String.self, forKey: .surname)
            self.name = try container.decode(String.self, forKey: .name)
        }
        
        private enum CodingKeys: String, CodingKey {
            case id = "Id"
            case username = "Username"
            case email = "Email"
            case forename = "Forename"
            case surname = "Surname"
            case name = "Name"
        }
        
        private enum SampleCodingKeys: String, CodingKey {
            case id = "Id"
        }
        
    }
    
    // MARK: - Constants
    
    /// The base url for making user service API requests.
    private static let apiURL = URL(string: "https://data.psc.ac.uk/api/user")!
    
}
