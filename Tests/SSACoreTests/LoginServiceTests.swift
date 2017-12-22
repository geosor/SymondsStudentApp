//
//  LoginServiceTests.swift
//  SSACoreTests
//
//  Created by Søren Mortensen on 21/12/2017.
//  Copyright © 2017 Søren Mortensen, George Taylor. All rights reserved.
//

import XCTest
@testable import SSACore

class LoginServiceTests: XCTestCase {
    
    // MARK: - XCTestCase
    
    /// :nodoc:
    override func setUp() {
        super.setUp()
        
        // We need to call `resetState()` before _and_ after each test so that we make sure we do it before the first
        // one begins and also after the last one ends.
        DataService.shared.loginService.resetState()
    }
    
    /// :nodoc:
    override func tearDown() {
        // We need to call `resetState()` before _and_ after each test so that we make sure we do it before the first
        // one begins and also after the last one ends.
        DataService.shared.loginService.resetState()
        
        super.tearDown()
    }
    
    // MARK: - Tests
    
    /// Test that the `DataService.LoginService` class is able to properly evaluate whether it meets sets of
    /// requirements for various `LoginService.State` values.
    func testRequirements() {
        // First check that the initial state is correct.
        XCTAssertEqual(DataService.shared.loginService.state, .loggedOut)
        
        // Now check that it's not possible to advance to the `.authorized` state, because we're missing an
        // authorization code.
        do {
            try DataService.shared.loginService.advanceState()
            XCTFail("""
                That call should have thrown a `DataService.LoginService.StateError.missingInformation` error. \
                Instead, it did not throw an error.
                """)
        } catch DataService.LoginService.StateError.missingInformation(let missing) {
            XCTAssertEqual(missing, [.authorizationCode], """
                The missing information should have been `[.authorizationCode]`. Instead, it was \(missing).
                """)
        } catch {
            XCTFail("""
                That call should have thrown a `DataService.LoginService.StateError.missingInformation` error. \
                Instead, it threw this error: \(error).
                """)
        }
        
        // Now give it an authorization code.
        DataService.shared.loginService.authorizationCode = "foo"
        
        // Now it should succeed!
        do {
            try DataService.shared.loginService.advanceState()
            // Make sure the new state is the right one.
            XCTAssertEqual(DataService.shared.loginService.state, .authorized)
        } catch {
            XCTFail("""
                That call should not have thrown an error. Instead, it threw this error: \(error).
                """)
        }
        
        // Now check that it's not possible to advance to the `.loggedIn` state, because we're missing an access token.
        do {
            try DataService.shared.loginService.advanceState()
            XCTFail("""
                That call should have thrown a `DataService.LoginService.StateError.missingInformation` error. \
                Instead, it did not throw an error.
                """)
        } catch DataService.LoginService.StateError.missingInformation(let missing) {
            XCTAssertEqual(missing, [.accessToken], """
                The missing information should have been `[.accessToken]`. Instead, it was \(missing).
                """)
        } catch {
            XCTFail("""
                That call should have thrown a `DataService.LoginService.StateError.missingInformation` error. \
                Instead, it threw this error: \(error).
                """)
        }
        
        // Now give it an access token.
        DataService.shared.loginService.accessToken = DataService.LoginService.AccessToken(
            accessToken: "bar",
            expiresIn: 42,
            tokenType: "baz",
            scope: "qux",
            refreshToken: "quux")
        
        // Now it should succeed!
        do {
            try DataService.shared.loginService.advanceState()
            // Make sure the new state is the right one.
            XCTAssertEqual(DataService.shared.loginService.state, .loggedIn)
        } catch {
            XCTFail("""
                That call should not have thrown an error. Instead, it threw this error: \(error).
                """)
        }
    }
    
}
