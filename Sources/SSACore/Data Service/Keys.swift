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
    
    // MARK: - Decodable
    
    private enum CodingKeys: String, CodingKey {
        case clientID = "client_id"
        case secret = "secret"
    }
    
}
