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
    public func makeRequest(completion: @escaping (Result<UserDetails>) -> Void) {
        var request = URLRequest(url: UserService.apiURL)
        request.addValue("Bearer \(self.accessToken.accessToken)",
            forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(.error(.unexpected(error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.error(.unexpected(nil)))
                return
            }
            
            guard httpResponse.statusCode == 200 else {
                completion(.error(.httpStatus(httpResponse.statusCode)))
                return
            }
            
            do {
                let userDetails = try JSONDecoder().decode(UserDetails.self, from: data)
                completion(.success(userDetails))
            } catch {
                completion(.error(.invalidData(error)))
            }
        }.resume()
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
        
        // MARK: Codable
        
        private enum CodingKeys: String, CodingKey {
            case id = "Id"
            case username = "Username"
            case email = "Email"
            case forename = "Forename"
            case surname = "Surname"
            case name = "Name"
        }
        
    }
    
    /// A result type, consisting either of a `.success`, containing some value, or an `.error`, containing an error.
    public enum Result<T> {
        case success(T)
        case error(UserService.Error)
    }
    
    /// Errors that might arise during `UserService` operations.
    public enum Error: Swift.Error {
        /// The data received from the user service is invalid.
        case invalidData(Swift.Error)
        /// An incorrect HTTP status code was received.
        case httpStatus(Int)
        /// An unexpected error occurred. If information was provided about the error, it is contained in the associated
        /// value.
        case unexpected(Swift.Error?)
    }
    
    // MARK: - Constants
    
    /// The base url for making user service API requests.
    private static let apiURL = URL(string: "https://data.psc.ac.uk/api/user")!
    
}
