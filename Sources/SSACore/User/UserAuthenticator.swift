//
//  UserAssembler.swift
//  SSACore
//
//  Created by Søren Mortensen on 10/01/2018.
//  Copyright © 2018 Søren Mortensen, George Taylor. All rights reserved.
//

import Foundation

/// Assembles a user as various pieces of information, including authentication information and details, are gathered.
public final class UserAuthenticator {
    
    // MARK: - Properties
    
    /// The current point in the login process the user is at.
    public private(set) var loginState: LoginState = .loggedOut {
        didSet {
            self.completions[self.loginState]?()
        }
    }
    
    /// This user's data service authorization code.
    public private(set) var authorizationCode: String?
    
    /// This user's data service access token.
    public private(set) var accessToken: LoginService.AccessToken?
    
    /// This user's user details.
    public private(set) var userDetails: UserService.UserDetails?
    
    /// Completion handlers to be run when various login states are reached.
    private var completions: [LoginState: () -> Void] = [:]
    
    // MARK: User
    
    /// Gets the user, given that the login state is `.haveDetails`.
    ///
    /// - Returns: The user, if there is one.
    /// - Throws: An error of type `UserAuthenticator.Error` if the state is not such that a user is present.
    public func getUser() throws -> User {
        guard let user = self.user, case .haveDetails = self.loginState else {
            if case .haveDetails = self.loginState {
                throw Error.noUser
            } else {
                throw Error.wrongState(actual: self.loginState, expected: .haveDetails)
            }
        }
        
        return user
    }
    
    /// The user, created from details recieved by `receiveUserDetails(_:forUserOfType:)` and stored in
    /// `self.userDetails`.
    private var user: User?
    
    // MARK: - Methods
    
    /// Receive an authorization code for this user, and set the user's state to `.authorizationCode` if it was
    /// `.loggedOut`.
    ///
    /// - Parameter code: The new authorization code.
    /// - Throws: An error of type `UserAuthenticator.Error` if `self.loginState` is not such that this authenticator is
    ///           able to accept an authorization code.
    public func receiveAuthorizationCode(_ code: String) throws {
        guard case .loggedOut = self.loginState else {
            throw Error.wrongState(actual: self.loginState, expected: .loggedOut)
        }
        
        self.authorizationCode = code
        self.loginState = .authorizationCode
    }
    
    /// Receive an access token for this user, and set the user's state to
    /// `.loggedIn` if it was `.authorizationCode`.
    ///
    /// - Parameter token: The new access token.
    /// - Throws: An error of type `UserAuthenticator.Error` if `self.loginState` is not such that this authenticator is
    ///           able to accept an access token.
    public func receiveAccessToken(_ token: LoginService.AccessToken) throws {
        guard case .authorizationCode = self.loginState else {
            switch self.loginState {
            case .loggedOut: throw Error.missingDetails(forState: .authorizationCode)
            default: throw Error.wrongState(actual: self.loginState, expected: .authorizationCode)
            }
        }
        
        self.accessToken = token
        self.loginState = .loggedIn
    }
    
    /// Receive user details and create a user, setting `self.loginState` to `.haveDetails` if it was `.loggedIn`.
    ///
    /// - Parameter userDetails: The user details.
    /// - Throws: An error of type `UserAuthenticator.Error` if `self.loginState` is not such that this authenticator is
    ///           able to accept user details.
    public func receiveUserDetails<T>(_ userDetails: UserService.UserDetails,
                                      forUserOfType userType: T.Type) throws where T: AuthenticatedUser {
        guard case .loggedIn = self.loginState else {
            switch self.loginState {
            case .authorizationCode: throw Error.missingDetails(forState: .loggedIn)
            default: throw Error.wrongState(actual: self.loginState, expected: .loggedIn)
            }
        }
        
        self.userDetails = userDetails
        
        let user = userType.init(userDetails: userDetails,
                                 authenticator: self)
        self.loginState = .haveDetails
        self.user = user
    }
    
    /// Logs out the user, regardless of the current login state of this authenticator.
    public func logOut() {
        self.authorizationCode = nil
        self.accessToken = nil
        self.userDetails = nil
        self.loginState = .loggedOut
    }
    
    /// Registers the given completion handler `completion` to run when the given state `state` is reached.
    ///
    /// - Parameters:
    ///   - state: The state to register the completion for.
    ///   - completion: The completion handler.
    /// - Throws: Throws an error if `state` is already associated with a completion handler.
    public func registerCompletion(for state: LoginState, completion: @escaping () -> Void) throws {
        guard self.completions[state] == nil else {
            throw Error.duplicateCompletion
        }
        
        self.completions[state] = completion
    }
    
    // MARK: - Initialisers
    
    public init() { }
    
    // MARK: - Types
    
    /// Defined points in the login process.
    public enum LoginState {
        /// The user has not logged in.
        case loggedOut
        /// The user has been given an authorization code but is not logged in.
        case authorizationCode
        /// The user is logged in.
        case loggedIn
        /// The user has provided details about themselves and we have created a model object to represent them.
        case haveDetails
    }
    
    /// Errors thrown by methods on `UserAuthenticator`.
    public enum Error: Swift.Error {
        case missingDetails(forState: LoginState)
        case wrongState(actual: LoginState, expected: LoginState)
        case noUser
        case duplicateCompletion
    }
    
}
