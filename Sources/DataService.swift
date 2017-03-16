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
    
    // MARK: - Initialisers
    
    /// A private initialiser to ensure that access to `DataService` is only through the `shared`
    /// singleton.
    private init() {}
    
}
