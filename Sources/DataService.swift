//
//  DataService.swift
//  SymondsStudentApp
//
//  Created by Søren Mortensen on 16/03/2017.
//  Copyright © 2017 Søren Mortensen, George Taylor. All rights reserved.
//

import Foundation

/// The `DataService` class provides functionality for interfacing with the Peter Symonds College
/// data service.
///
/// This includes authentication and retrieval of information from the Timetable, Find, Room
/// Timetable, and User services.
public class DataService {
    
    // MARK: - Properties
    
    /// Singleton instance of `DataService`.
    public static var shared = DataService()
    
    /// The URL used for retrieving an access token.
    public var getAccessTokenURL: URL {
        let queryItems = [
            URLQueryItem(
                name: "client_id",
                value: self.keys?.clientID ?? ""),
            URLQueryItem(
                name: "response_type",
                value: "code"),
            URLQueryItem(
                name: "redirect_uri",
                value: self.redirectURL.absoluteString)
        ]
        
        var components = URLComponents(
            url: self.authURL,
            resolvingAgainstBaseURL: false)!
        components.queryItems = queryItems
        return components.url!
    }
    
    /// The redirect URL, passed to the Symonds Data Service in authentication requests.
    ///
    /// Apart from being required by the Data Service, this redirect URL enables a return to the
    /// host application after authenticating externally.
    public let redirectURL = URL(string: "app://com.sorenmortensen.SymondsStudentApp")!
    
    /// A pair of keys used for authentication with the Symonds Data Service.
    ///
    /// These keys are secret and are therefore loaded from a JSON file that is copied into the main
    /// bundle at build time.
    private let keys: (clientID: String, secret: String)? = {
        guard let keysURL = Bundle.main.url(forResource: "keys", withExtension: "json") else {
            NSLog("Data Service could not retrieve keys.json resource.")
            return nil
        }
        
        guard
            let data = try? Data(contentsOf: keysURL),
            let keys = try? JSONSerialization.jsonObject(with: data) as? [String: String]
            else {
                NSLog("Data from keys.json is invalid.")
                return nil
        }
        
        guard let clientID: String = keys?["client_id"] else {
            NSLog("Could not retrieve client ID from keys.json.")
            return nil
        }
        
        guard let secret: String = keys?["secret"] else {
            NSLog("Could not retrieve secret from keys.json.")
            return nil
        }
        
        return (
            clientID: clientID,
            secret: secret
        )
    }()
    
    /// The result of the most recent authentication.
    private var authenticationResult: AuthenticationResult?
    
    /// A shared session used for sending network requests.
    private let session = URLSession(configuration: .default)
    
    /// The URL where authentication requests are sent.
    private let authURL = URL(string: "https://data.psc.ac.uk/oauth/v2/auth")!
    
    /// The URL where token exchange requests are sent.
    private let tokenURL = URL(string: "https://data.psc.ac.uk/oauth/v2/token")!
    
    // MARK: - Types
    
    /// The result of an authentication request sent to the Symonds Data Service.
    public struct AuthenticationResult {
        
        // MARK: Properties
        
        /// The provided access token, usable for the amount of time specified by `expiresIn`.
        public let accessToken: String
        
        /// The amount of time after which the access token will expire.
        public let expiresIn: Int
        
        /// The type of token provided.
        public let tokenType: String
        
        /// The scope of the provided token.
        public let scope: String
        
        /// A refresh token that can be used to retrieve another access token.
        public let refreshToken: String
        
        /// A string key used for persisting `refreshToken` in Keychain.
        private static let refreshTokenKey = "refreshToken"
        
        // MARK: Initialisers
        
        /// Creates an instance of `AuthenticationResult`.
        ///
        /// - Parameters:
        ///   - accessToken: The access token.
        ///   - expiresIn: The amount of time before expiration.
        ///   - tokenType: The type of token.
        ///   - scope: The scope of the token.
        ///   - refreshToken: The refresh token.
        internal init(accessToken: String,
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
        public func saveRefreshTokenToKeychain() {
            do {
                let tokenItem = KeychainPasswordItem(
                    service: KeychainConfiguration.serviceName,
                    account: AuthenticationResult.refreshTokenKey,
                    accessGroup: KeychainConfiguration.accessGroup)
                try tokenItem.savePassword(refreshToken)
            } catch {
                fatalError("Could not save token")
            }
        }
        
        /// Reads a refresh token value from Keychain.
        ///
        /// - Returns: The token if found, otherwise `nil`.
        public static func readRefreshToken() -> String? {
            do {
                let tokenItem = KeychainPasswordItem(
                    service: KeychainConfiguration.serviceName,
                    account: AuthenticationResult.refreshTokenKey,
                    accessGroup: KeychainConfiguration.accessGroup)
                let token = try tokenItem.readPassword()
                return token
            } catch {
                NSLog("Could not read token")
                return nil
            }
        }
        
    }
    
    /// A type of grant that can be used to request an access token from the Symonds Data Service.
    public enum GrantType: String {
        
        /// An authorisation code.
        case authorisationCode = "authorization_code"
        
        /// A refresh token.
        case refreshToken = "refresh_token"
        
    }
    
    /// An error.
    public enum Error: Swift.Error {
        
        /// The client ID and secret could not be retrieved or were invalid.
        case invalidKeys
        
        /// No saved authentication details were present.
        case noSavedDetails
        
        /// The authentication code returned by the Data Service was invalid or not present.
        case invalidAuthenticationCode
        
        /// An access token returned by the Data Service was invalid or not present.
        case invalidAccessToken
        
        /// Authentication with the Data Service was unsuccessful.
        case authenticationFailed
        
        /// The user's timetable could not be retrieved from the Data Service.
        case unableToRetrieveTimetable
        
        /// The retrieved data for the user's timetable was invalid.
        case invalidTimetable
        
        /// An unexpected error.
        case unexpectedError(error: Swift.Error?)
        
    }
    
    // MARK: - Initialisers
    
    /// A private initialiser to ensure that access to `DataService` is only through the `shared`
    /// singleton.
    private init() {}
    
    // MARK: - Functions
    
    // MARK: Authentication
    
    /// A typealias used only in `authenticateFromSavedDetails(completion:)` to simplify the
    /// declaration.
    ///
    /// - Parameters:
    ///   - error: An error if one occurred during the request; otherwise `nil`.
    public typealias AuthenticationCompletion = (
        _ error: DataService.Error?
    ) -> Void
    
    /// Attempts to use saved authentication details from Keychain to authenticate with the Data
    /// Service.
    ///
    /// - Parameters:
    ///   - completion: Called when the request completes.
    public func authenticateFromSavedDetails(completion: @escaping AuthenticationCompletion) {
        guard let refreshToken = AuthenticationResult.readRefreshToken() else {
            completion(.noSavedDetails)
            return
        }
        
        self.exchangeCodeForToken(refreshToken, grantType: .refreshToken) { _, error in
            if let _ = error {
                NSLog("Authentication failed!")
                completion(.authenticationFailed)
            } else {
                completion(nil)
            }
        }
    }
    
    /// A typealias used only in exchangeCodeForToken(_:completion:) in order to simplify the
    /// declaration of the completion block.
    ///
    /// - Parameters:
    ///   - result: The authentication result.
    ///   - error: An error, if one occurred.
    public typealias ExchangeCompletion = (
        _ result: DataService.AuthenticationResult?,
        _ error: DataService.Error?
    ) -> Void
    
    /// Exchanges an authorisation code for an access token.
    ///
    /// - Parameters:
    ///   - code: The authorisation code to exchange.
    ///   - completion: Called when the network request completes.
    public func exchangeCodeForToken(_ code: String,
                                     grantType: GrantType,
                                     completion: @escaping ExchangeCompletion) {
        guard !code.isEmpty else {
            completion(
                nil,
                .invalidAuthenticationCode)
            return
        }
        
        let query: String
        do {
            query = try generateExchangePOSTString(
                with: code,
                grantType: grantType)
        } catch(let error as DataService.Error) {
            completion(nil, error)
            return
        } catch {
            completion(
                nil,
                .unexpectedError(error: error))
            return
        }
        
        let body = query.data(using: .utf8)!
        
        let request = URLRequest(
            url: self.tokenURL,
            httpMethod: "POST",
            httpBody: body
        )
        
        let task = session.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else {
                NSLog("Error retrieving access token: \(error)")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse,
                httpStatus.statusCode != 200 {
                NSLog("Login task statusCode should be 200, but is " +
                    "\(httpStatus.statusCode)")
                NSLog("response = \(String(describing: response))")
            }
            
            do {
                let authResult = try self.serializeLoginResponse(from: data)
                self.authenticationResult = authResult
                self.authenticationResult!.saveRefreshTokenToKeychain()
                completion(authResult, nil)
            } catch(let error as DataService.Error) {
                completion(nil, error)
                return
            } catch {
                completion(
                    nil,
                    .unexpectedError(error: error))
                return
            }
        }
        
        task.resume()
    }
    
    /// Generates an HTTP POST string to exchange an authorisation code for an access token.
    ///
    /// - Parameter code: The authorisation code to use for authentication when requesting a token.
    ///
    /// - Returns: The generated string.
    ///
    /// - Throws: An error of type `AuthenticationError` in the event of a relevant error.
    private func generateExchangePOSTString(with code: String,
                                            grantType: GrantType) throws -> String {
        guard
            let clientID = keys?.clientID,
            let secret = keys?.secret
            else {
                throw Error.invalidKeys
        }
        
        let queryItems = [
            URLQueryItem(name: "client_id", value: clientID),
            URLQueryItem(name: "client_secret", value: secret),
            URLQueryItem(name: "grant_type", value: grantType.rawValue),
            URLQueryItem(name: "redirect_uri",
                         value: redirectURL.absoluteString),
            URLQueryItem(name: "code", value: code)
        ]
        
        let components = URLComponents(string: "", queryItems: queryItems)!
        
        return components.query!
    }
    
    /// Creates an `AuthenticationResult` instance from a JSON object returned by the Symonds Data
    /// Service.
    ///
    /// - Parameter data: The data returned by the Symonds Data Service.
    ///
    /// - Throws: Throws errors of type `AuthenticationError` in the event of a relevant error.
    private func serializeLoginResponse(from data: Data) throws -> AuthenticationResult {
        guard
            let serialized = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let accessToken = serialized?["access_token"] as? String,
            let expiresIn = serialized?["expires_in"] as? Int,
            let tokenType = serialized?["token_type"] as? String,
            let scope = serialized?["scope"] as? String,
            let refreshToken = serialized?["refresh_token"] as? String
            else {
                throw Error.invalidAccessToken
        }
        
        let auth = AuthenticationResult(
            accessToken: accessToken,
            expiresIn: expiresIn,
            tokenType: tokenType,
            scope: scope,
            refreshToken: refreshToken
        )
        
        return auth
    }
    
}
