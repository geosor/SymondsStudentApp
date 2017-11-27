//
//  URLComponents.swift
//  SymondsStudentApp
//
//  Created by Søren Mortensen on 17/03/2017.
//  Copyright © 2017 Søren Mortensen, George Taylor. All rights reserved.
//

import Foundation

/// :nodoc:
internal extension URLComponents {
    
    /// :nodoc:
    internal init?(string: String, queryItems: [URLQueryItem]) {
        self.init(string: string)
        self.queryItems = queryItems
    }
    
}
