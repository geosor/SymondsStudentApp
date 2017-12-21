//
//  DataServiceTests.swift
//  SymondsStudentAppTests
//
//  Created by Søren Mortensen on 21/12/2017.
//  Copyright © 2017 Søren Mortensen, George Taylor. All rights reserved.
//

import XCTest
@testable import SymondsStudentApp

class DataServiceTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        DataService.shared.resetState()
    }
    
    override func tearDown() {
        DataService.shared.resetState()
        
        super.tearDown()
    }
    
    // MARK: - DataService.LoginInformation
    
    /// Test that the `DataService.LoginInformation` struct is able to properly evaluate whether it meets sets of
    /// requirements for various `DataService.LoginState` values.
    func test_requirements() {
        // Declare variables to reuse for storing the results of various checks against requirements.
        var satisfiedLoggedOut: Bool
        var satisfiesAuth: Bool
        var satisfiesLoggedIn: Bool
        
        // Before changing anything, check that the requirements are met for the `.loggedOut` state (the requirements
        // for this state are empty).
        satisfiedLoggedOut = DataService.shared.loginInformation.satisfiesRequirements(for: .loggedOut)
        XCTAssertTrue(satisfiedLoggedOut)
        
        // Check that the requirements for `.authorized` are not met (we would need an authorization code).
        satisfiesAuth = DataService.shared.loginInformation.satisfiesRequirements(for: .authorized)
        XCTAssertFalse(satisfiesAuth)
        
        // Check that the requirements for `.loggedIn` are not met (we would need an access token and to meet the
        // requirements for `.authorized` as well.
        satisfiesLoggedIn = DataService.shared.loginInformation.satisfiesRequirements(for: .loggedIn)
        XCTAssertFalse(satisfiesLoggedIn)
        
        // Now set an authorization code.
        DataService.shared.loginInformation.authorizationCode = "foo"
        
        // This should still be true.
        satisfiedLoggedOut = DataService.shared.loginInformation.satisfiesRequirements(for: .loggedOut)
        XCTAssertTrue(satisfiedLoggedOut)
        
        // This should now be true! We have an authorization code now.
        satisfiesAuth = DataService.shared.loginInformation.satisfiesRequirements(for: .authorized)
        XCTAssertTrue(satisfiesAuth)
        
        // This should still be false, because we don't have an access token.
        satisfiesLoggedIn = DataService.shared.loginInformation.satisfiesRequirements(for: .loggedIn)
        XCTAssertFalse(satisfiesLoggedIn)
        
        // Now set an access token.
        DataService.shared.loginInformation.accessToken = DataService.AccessToken(accessToken: "bar",
                                                                                  expiresIn: 0,
                                                                                  tokenType: "baz",
                                                                                  scope: "qux",
                                                                                  refreshToken: "quux")
        
        // This should still be true.
        satisfiedLoggedOut = DataService.shared.loginInformation.satisfiesRequirements(for: .loggedOut)
        XCTAssertTrue(satisfiedLoggedOut)
        
        // This should still be true.
        satisfiesAuth = DataService.shared.loginInformation.satisfiesRequirements(for: .authorized)
        XCTAssertTrue(satisfiesAuth)
        
        // This should now be true! We have an access token now.
        satisfiesLoggedIn = DataService.shared.loginInformation.satisfiesRequirements(for: .loggedIn)
        XCTAssertTrue(satisfiesLoggedIn)
    }
    
    /// Test that the wrappers that `DataService.LoginInformation` keeps around its properties work correctly.
    ///
    /// Because of the comparison mechanics involving `KeyPath`s inside `DataService.LoginInformation`, we can't use
    /// optionals. Instead, there's a private struct `Data` with two cases `.none` and `.some`, very similar to
    /// `Optional` itself, and the exposed properties translate between these values and `Optional` values on get and
    /// set. This test simply checks that that process works properly.
    func test_wrapperAroundData() {
        var loginInformation = DataService.LoginInformation()
        
        // Initially, all the properties should be `.none` under the hood, so they should be `nil` externally.
        XCTAssertNil(loginInformation.authorizationCode)
        XCTAssertNil(loginInformation.accessToken)
        
        // If we set values in both of the properties...
        loginInformation.authorizationCode = "foo"
        loginInformation.accessToken = DataService.AccessToken(accessToken: "bar",
                                                               expiresIn: 0,
                                                               tokenType: "baz",
                                                               scope: "qux",
                                                               refreshToken: "quux")
        
        // ...they should be set to `.some` under the hood, and so should not be nil externally.
        XCTAssertNotNil(loginInformation.authorizationCode)
        XCTAssertNotNil(loginInformation.accessToken)
        
        // Then if we set them back to `nil`...
        loginInformation.authorizationCode = nil
        loginInformation.accessToken = nil
        
        // ...they should be `.none` under the hood again, so should be `nil` externally. It's important to perform this
        // step to check that they're correctly set to `.none` as well as simply being `nil` when they're initally
        // `.none`.
        XCTAssertNil(loginInformation.authorizationCode)
        XCTAssertNil(loginInformation.accessToken)
    }
    
}
