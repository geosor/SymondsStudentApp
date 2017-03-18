//
//  AppDelegate.swift
//  SymondsStudentApp
//
//  Created by Søren Mortensen on 14/03/2017.
//  Copyright © 2017 Søren Mortensen, George Taylor. All rights reserved.
//

import UIKit

/// The delegate of the currently running `UIApplication` instance.
@UIApplicationMain
internal class AppDelegate: UIResponder, UIApplicationDelegate {
    
    // MARK: - Properties
    
    /// The current instance of `SplashViewController` that has registered itself with
    /// `AppDelegate`. This is the instance to which completion callbacks will be sent.
    internal weak var splashViewController: SplashViewController?
    
    /// The current instance of `LoginViewController` that has registered itself with `AppDelegate`.
    /// This the instance to which completion callbacks will be sent.
    internal weak var loginViewController: LoginViewController?
    
    // MARK: - UIApplicationDelegate
    
    /// :nodoc:
    internal var window: UIWindow?
    
    /// :nodoc:
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplicationOpenURLOptionsKey: Any] = [:]) -> Bool {
        // Parse the URL to extract its components.
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            // Returning false indicates that we were not able to handle the URL
            // correctly.
            return false
        }
        
        guard components.scheme == "app" else {
            return false
        }
        
        guard components.host == "com.sorenmortensen.SymondsStudentApp" else {
            return false
        }
        
        // The data service gives us back an authorization code by putting it in a query item with
        // the name "code". So check if one of the query items has the name "code".
        guard let codeItem = components.queryItems?.first(where: { $0.name == "code" }) else {
            return false
        }
        
        guard let code = codeItem.value else {
            return false
        }
        
        // Tell the login view controller that the code has been recieved.
        self.loginViewController?.codeRecievedCompletion()
        
        guard let splash = self.splashViewController else {
            return false
        }
        
        DataService.shared.exchangeCodeForToken(
            code,
            grantType: .authorisationCode,
            completion: splash.codeExchangeCompletion)
        
        return true
    }
    
}
