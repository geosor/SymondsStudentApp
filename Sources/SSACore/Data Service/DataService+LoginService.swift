//
//  DataService+LoginService.swift
//  SSACore
//
//  Created by Søren Mortensen on 21/12/2017.
//  Copyright © 2017 Søren Mortensen, George Taylor. All rights reserved.
//

import Foundation

extension DataService {
    
    /// Handles tasks related to authentication with the data service.
    ///
    /// Instances of this class track where in the process of authentication they are currently using
    /// `LoginService.State`.
    public class LoginService {
        
        // MARK: - Life Cycle
        
        /// Creates a new instance of `DataService.LoginService`.
        init() {
            self.state = .loggedOut
        }
        
        // MARK: - Constants
        
        /// The URL where authentication requests are sent.
        let authURL = URL(string: "https://data.psc.ac.uk/oauth/v2/auth")!
        
        /// The URL where token exchange requests are sent.
        let tokenURL = URL(string: "https://data.psc.ac.uk/oauth/v2/token")!
        
        // MARK: - State
        
        /// Represents each of the states the login service can be in, with respect to the login process.
        public enum State {
            
            /// Not logged in. The login service does not hold any information about credentials.
            case loggedOut
            
            /// The process of retrieving an authorization code has completed.
            case authorized
            
            /// Logged in, holding an access token.
            case loggedIn
            
            /// Returns the next state after the state `state`.
            ///
            /// - Throws: Throws a `LoginService.StateError.finalState` error if `state` is the final state (and
            ///           therefore there is no next state).
            static func nextState(after state: State) throws -> State {
                switch state {
                case .loggedOut: return .authorized
                case .authorized: return .loggedIn
                case .loggedIn: throw StateError.finalState
                }
            }
            
            var requirements: Set<Information> {
                switch self {
                case .loggedOut: return []
                case .authorized: return [.authorizationCode]
                case .loggedIn: return State.authorized.requirements.union([.accessToken])
                }
            }
            
        }
        
        /// The current login state of the login service.
        public private(set) var state: State
        
        /// Attempts to advance to the next state.
        ///
        /// - Throws: Throws an error of type `StateError` if unable to advance to the next state, to indicate the
        ///           reason for the failure to advance.
        func advanceState() throws {
            // Throws a `StateError.finalState` if there is no next state.
            let nextState = try State.nextState(after: self.state)
            
            // Go through all the requirements for the next state and check if they've been met.
            let missing: Set = nextState.requirements.filter { req in
                switch req {
                case .authorizationCode: return self.authorizationCode == nil
                case .accessToken: return self.accessToken == nil
                }
            }
            
            // Make sure none are missing.
            guard missing.isEmpty else {
                // If there are some missing, we can't advance, so throw an error to indicate which ones are missing.
                throw StateError.missingInformation(missing)
            }
            
            // Advance to the next state.
            self.state = nextState
        }
        
        /// Resets the data service login state, removing all authentication information from this session, effectively
        /// logging out.
        func resetState() {
            self.state = .loggedOut
        }
        
        /// Errors relating to the login state.
        public enum StateError: Swift.Error {
            
            /// Indicates that information is missing that is required to advance to the next state.
            case missingInformation(Set<Information>)
            
            /// Indicates that the state cannot be advanced, because the current state is the final one.
            case finalState
            
        }
        
        // MARK: - Information
        
        /// The current authorization code, if there is one.
        var authorizationCode: String?
        
        /// The current access token, if there is one.
        var accessToken: AccessToken?
        
        /// Represents each of the pieces of information that needed/gathered at various stages of the login process.
        public enum Information {
            
            /// An OAuth authorization code.
            case authorizationCode
            
            /// An OAuth access token.
            case accessToken
            
        }
        
        /// A token that provides access to the Symonds Data Service.
        struct AccessToken {
            
            // MARK: Properties
            
            /// The provided access token, usable for the amount of time specified by `expiresIn`.
            let accessToken: String
            
            /// The amount of time after which the access token will expire.
            let expiresIn: Int
            
            /// The type of token provided.
            let tokenType: String
            
            /// The scope of the provided token.
            let scope: String
            
            /// A refresh token that can be used to retrieve another access token.
            let refreshToken: String
            
            /// A string key used for persisting `refreshToken` in Keychain.
            private static let refreshTokenKey = "refreshToken"
            
            // MARK: Initialisers
            
            /// Creates an instance of `AccessToken`.
            ///
            /// - Parameters:
            ///   - accessToken: The access token.
            ///   - expiresIn: The amount of time before expiration.
            ///   - tokenType: The type of token.
            ///   - scope: The scope of the token.
            ///   - refreshToken: The refresh token.
            init(accessToken: String,
                 expiresIn: Int,
                 tokenType: String,
                 scope: String,
                 refreshToken: String) {
                self.accessToken = accessToken
                self.expiresIn = expiresIn
                self.tokenType = tokenType
                self.scope = scope
                self.refreshToken = refreshToken
            }
            
            /// Saves `refreshToken` into Keychain.
            func saveRefreshToken() throws {
                let tokenItem = KeychainPasswordItem(
                    service: KeychainConfiguration.serviceName,
                    account: AccessToken.refreshTokenKey,
                    accessGroup: KeychainConfiguration.accessGroup)
                try tokenItem.savePassword(refreshToken)
            }
            
            /// Reads a refresh token value from Keychain.
            ///
            /// - Returns: The token if found, otherwise `nil`.
            static func readRefreshToken() throws -> String {
                let tokenItem = KeychainPasswordItem(
                    service: KeychainConfiguration.serviceName,
                    account: AccessToken.refreshTokenKey,
                    accessGroup: KeychainConfiguration.accessGroup)
                return try tokenItem.readPassword()
            }
            
        }
        
        // MARK: - Authentication
        
        /// A pair of keys used for authentication with the Symonds Data Service.
        ///
        /// These keys are secret and are therefore loaded (using `loadKeys()`) from a JSON file that is copied into
        /// the main bundle at build time.
        private struct Keys: Decodable {
            
            /// The client ID.
            var clientID: String
            
            /// The secret.
            var secret: String
            
        }
        
        /// Loads the client ID and secret from their JSON file.
        ///
        /// - Returns: The keys.
        /// - Throws: An error if the keys could not be loaded.
        private func loadKeys() throws -> Keys {
            guard let keysURL = Bundle.main.url(forResource: "keys", withExtension: "json") else {
                throw AuthError.missingKeys
            }
            
            guard let data = try? Data(contentsOf: keysURL) else {
                throw AuthError.missingKeys
            }
            
            do {
                return try JSONDecoder().decode(Keys.self, from: data)
            } catch {
                throw AuthError.invalidKeys
            }
        }
        
        /// Errors relating to the authentication process.
        public enum AuthError: Swift.Error {
            
            /// The authentication keys are missing.
            case missingKeys
            
            /// The authentication keys could not be read.
            case invalidKeys
            
        }
        
    }
    
}
