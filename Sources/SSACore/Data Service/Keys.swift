//
//  Keys.swift
//  SSACore
//
//  Created by Søren Mortensen on 10/01/2018.
//  Copyright © 2018 Søren Mortensen, George Taylor. All rights reserved.
//

import Foundation

/// A pair of keys used for authentication with the Symonds Data Service.
///
/// These keys are secret and should therefore be stored in an encrypted format. The recommended method of storage is an
/// encrypted JSON file in the following format (which allows instances of `Keys` to be directly created using a
/// `JSONDecoder`):
///
/// ```
/// {
///     "client_id": "client_id_goes_here",
///     "secret": "secret_goes_here"
/// }
/// ```
public struct Keys: Decodable {
    
    /// The client ID.
    public var clientID: String
    
    /// The secret.
    public var secret: String
    
    public static var shared: Keys = {
        do {
            guard let url = Bundle.main.url(forResource: "keys", withExtension: "json") else {
                throw NSError(domain: "com.sorenmortensen.SymondsStudentApp", code: 314159, userInfo: nil)
            }
            
            let fileData = try Data(contentsOf: url)
            return try JSONDecoder().decode(Keys.self, from: fileData)
        } catch {
            fatalError("Error while settings keys: \(error)")
        }
    }()
    
    // MARK: - Decodable
    
    private enum CodingKeys: String, CodingKey {
        case clientID = "client_id"
        case secret = "secret"
    }
    
}
