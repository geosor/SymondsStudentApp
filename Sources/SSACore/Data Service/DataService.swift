//
//  DataService.swift
//  SSACore
//
//  Created by Søren Mortensen on 10/01/2018.
//  Copyright © 2018 Søren Mortensen, George Taylor. All rights reserved.
//

import Foundation

/// A `DataService` is the local interface to one of the services provided by the Symonds data service.
public protocol DataService {
    
    /// An initialiser that stores a set of `Keys` for authentication with the data service.
    init(keys: Keys)
    
}
