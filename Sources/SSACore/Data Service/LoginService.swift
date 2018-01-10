//
//  LoginService.swift
//  SSACore
//
//  Created by Søren Mortensen on 10/01/2018.
//  Copyright © 2018 Søren Mortensen, George Taylor. All rights reserved.
//

import Foundation

/// Service that handles authentication/login with the Symonds data service.
public final class LoginService: DataService {
    
    // MARK: - Properties
    
    /// Keys for authentication with the data service.
    private let keys: Keys
    
    /// The redirect URL, passed to the Symonds data service in authentication requests. You should set this to a value
    /// specific to your app.
    ///
    /// Apart from being required by the data service, this redirect URL enables a return to the host application after
    /// authenticating externally.
    ///
    /// The default value of this property is the URL `app://localhost`.
    public var redirectURL = URL(string: "app://localhost")!
    
    /// The URL used for retrieving an access token.
    public var getAccessTokenURL: URL {
        let queryItems = [
            URLQueryItem(
                name: "client_id",
                value: self.keys.clientID),
            URLQueryItem(
                name: "response_type",
                value: "code"),
            URLQueryItem(
                name: "redirect_uri",
                value: self.redirectURL.absoluteString)
        ]
        
        var components = URLComponents(
            url: LoginService.authURL,
            resolvingAgainstBaseURL: false)!
        components.queryItems = queryItems
        return components.url!
    }
    
    // MARK: - Initialisers
    
    public convenience init(keys: Keys, redirectURL: URL) {
        self.init(keys: keys)
        self.redirectURL = redirectURL
    }
    
    // MARK: - Authentication
    
    /// A typealias representing a completion handler passing in a `Result` over any type `T`.
    ///
    /// - Parameter result: The result of the operation.
    public typealias ResultCompletion<T> = (_ result: Result<T>) -> Void
    
    /// A typealias used only in `retrieveAccessToken(_:grantType:completion:)` to simplify the declaration.
    public typealias AccessTokenCompletion = ResultCompletion<AccessToken>
    
    /// Retrieves an access token from the data service, in exchange for the provided `code`.
    ///
    /// - Parameters:
    ///   - code: A code suitable for exchange for an access token. This can be either type of code described by
    ///           `GrantType`: namely an authorization code or a refresh token. The value of the `grantType` parameter
    ///           must match the type of code provided, or the attempt will fail.
    ///   - grantType: The type of code provided by the `code` parameter.
    ///   - completion: A completion handler to run when the request completes, to handle the result.
    public func retrieveAccessToken(_ code: String, grantType: GrantType, completion: @escaping AccessTokenCompletion) {
        guard !code.isEmpty else {
            return completion(.error(.invalidAuthenticationCode))
        }
        
        let query: String
        do {
            query = try generateExchangePOSTString(with: code, grantType: grantType)
        } catch let error as LoginService.Error {
            return completion(.error(error))
        } catch {
            return completion(.error(.unexpectedError(error)))
        }
        
        let body = query.data(using: .utf8)!
        let request = URLRequest(url: LoginService.tokenURL, httpMethod: "POST", httpBody: body)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                return completion(.error(.unexpectedError(error)))
            }
            
            guard let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode == 200 else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode
                return completion(.error(.invalidHTTPStatus(statusCode)))
            }
            
            do {
                let accessToken = try JSONDecoder().decode(AccessToken.self, from: data)
                return completion(.success(accessToken))
            } catch {
                return completion(.error(.invalidAccessToken))
            }
        }
        
        task.resume()
    }
    
    /// Generates an HTTP POST string to exchange a code for an access token.
    ///
    /// - Parameters:
    ///   - code:  The authorisation code to use for authentication when requesting a token.
    ///   - grantType: The type of code provided by the `code` parameter.
    /// - Returns: The generated string.
    /// - Throws: An error of type `LoginService.Error` in the event of a relevant error.
    private func generateExchangePOSTString(with code: String, grantType: GrantType) throws -> String {
        let queryItems = [
            URLQueryItem(name: "client_id", value: self.keys.clientID),
            URLQueryItem(name: "client_secret", value: self.keys.secret),
            URLQueryItem(name: "grant_type", value: grantType.rawValue),
            URLQueryItem(name: "redirect_uri", value: redirectURL.absoluteString),
            URLQueryItem(name: "code", value: code)
        ]
        
        let components = URLComponents(string: "", queryItems: queryItems)!
        return components.query!
    }
    
    // MARK: - Constants
    
    /// The URL where authentication requests are sent.
    private static let authURL = URL(string: "https://data.psc.ac.uk/oauth/v2/auth")!
    
    /// The URL where token exchange requests are sent.
    private static let tokenURL = URL(string: "https://data.psc.ac.uk/oauth/v2/token")!
    
    // MARK: - Types
    
    /// A token that provides access to the Symonds data service.
    public struct AccessToken: Decodable {
        
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
        
        // MARK: Static Functions
        
        /// Attempts to save `self.refreshToken` into Keychain using the given configuration.
        public func saveRefreshToken(configuration: KeychainConfiguration) throws {
            let tokenItem = KeychainPasswordItem(
                service: configuration.serviceName,
                account: AccessToken.refreshTokenKey,
                accessGroup: configuration.accessGroup)
            try tokenItem.savePassword(refreshToken)
        }

        /// Attempts to load a refresh token value from Keychain.
        public static func loadRefreshToken(configuration: KeychainConfiguration) throws -> String {
            let tokenItem = KeychainPasswordItem(
                service: configuration.serviceName,
                account: AccessToken.refreshTokenKey,
                accessGroup: configuration.accessGroup)
            return try tokenItem.readPassword()
        }
        
        // MARK: Decodable
        
        private enum CodingKeys: String, CodingKey {
            case accessToken = "access_token"
            case expiresIn = "expires_in"
            case tokenType = "token_type"
            case scope = "scope"
            case refreshToken = "refresh_token"
        }
        
    }
    
    /// A type of grant that can be used to request an access token from the Symonds Data Service.
    public enum GrantType: String {
        
        /// An authorisation code.
        case authorisationCode = "authorization_code"
        
        /// A refresh token.
        case refreshToken = "refresh_token"
        
    }
    
    /// Errors thrown by `LoginService`.
    public enum Error: Swift.Error {
        
        /// The authentication code was invalid or not present.
        case invalidAuthenticationCode
        
        /// The access token was invalid or not present.
        case invalidAccessToken
        
        /// An invalid HTTP status code was received during the request.
        case invalidHTTPStatus(Int?)
        
        /// Authentication with the Data Service was unsuccessful.
        case authenticationFailed
        
        /// An unexpected error.
        case unexpectedError(Swift.Error?)
        
    }
    
    /// The result of an operation. The result is either a success, in which it contains an instance of type `T`, the
    /// payload type, or an error, in which case it contains a `LoginService.Error` describing the error.
    public enum Result<T> {
        case success(T)
        case error(LoginService.Error)
    }
    
    // MARK: - DataService
    
    public init(keys: Keys) {
        self.keys = keys
    }
    
}
