//
//  URLRequest.swift
//  SSACore
//
//  Created by Søren Mortensen on 17/03/2017.
//  Copyright © 2017 Søren Mortensen, George Taylor. All rights reserved.
//

import Foundation

/// :nodoc:
internal extension URLRequest {
    
    /// :nodoc:
    internal init(url: URL, httpMethod: String, httpBody: Data) {
        self.init(url: url)
        self.httpMethod = httpMethod
        self.httpBody = httpBody
    }
    
}
