//
//  AppDelegate.swift
//  SymondsStudentApp
//
//  Created by Søren Mortensen on 14/03/2017.
//  Copyright © 2017 Søren Mortensen, George Taylor. All rights reserved.
//

import UIKit
import SSACore

/// The delegate of the currently running `UIApplication` instance.
@UIApplicationMain
internal class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var userAuthenticator: UserAuthenticator?
    
    // MARK: - UIApplicationDelegate
    
    /// :nodoc:
    internal var window: UIWindow?
    
    /// :nodoc:
    func applicationDidFinishLaunching(_ application: UIApplication) {
        // Dynamic shortcut items. The static ones are defined in Metadata/Info.plist under the
        // UIApplicationShortcutItems key.
        UIApplication.shared.shortcutItems = []
        
        // Set the redirect URL.
        LoginService.redirectURL = URL(string: "app://com.sorenmortensen.SymondsStudentApp")!
    }
    
    /// :nodoc:
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplicationOpenURLOptionsKey: Any] = [:]) -> Bool {
        // Parse the URL to extract its components.
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            // Returning false indicates that we were not able to handle the URL correctly.
            return false
        }
        
        guard components.scheme == "app" else {
            return false
        }
        
        guard components.host == "com.sorenmortensen.SymondsStudentApp" else {
            return false
        }
        
        // The data service gives us back an authorization code by putting it in a query item with the name "code". So
        // check if one of the query items has the name "code".
        guard let codeItem = components.queryItems?.first(where: { $0.name == "code" }) else {
            return false
        }
        
        guard let code = codeItem.value else {
            return false
        }
        
        do {
            try self.userAuthenticator?.receiveAuthorizationCode(code)
        } catch {
            print(error)
        }
        
        return true
    }
    
    /// :nodoc:
    func application(_ application: UIApplication,
                     performActionFor shortcutItem: UIApplicationShortcutItem,
                     completionHandler: @escaping (Bool) -> Void) {
        switch shortcutItem.type {
        case "com.sorenmortensen.SymondsStudentApp.opentimetable":
            break
        case "com.sorenmortensen.SymondsStudentApp.openfreerooms":
            break
        default:
            print("Unrecognised shortcut")
        }
    }
    
}
