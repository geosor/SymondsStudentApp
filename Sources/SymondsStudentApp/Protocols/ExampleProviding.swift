//
//  ExampleProviding.swift
//  SymondsStudentApp
//
//  Created by Søren Mortensen on 16/12/2017.
//  Copyright © 2017 Søren Mortensen, George Taylor. All rights reserved.
//

import Foundation

/// A type that is `ExampleProviding` is a type that provides example data.
internal protocol ExampleProviding {
    
    /// The type of the example data that the implementing type provides.
    associatedtype T
    // swiftlint:disable:previous type_name
    
    /// The example data.
    static var example: T { get }
    
}
