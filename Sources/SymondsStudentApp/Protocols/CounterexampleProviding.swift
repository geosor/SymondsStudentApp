//
//  CounterexampleProviding.swift
//  SymondsStudentApp
//
//  Created by Søren Mortensen on 16/12/2017.
//  Copyright © 2017 Søren Mortensen, George Taylor. All rights reserved.
//

import Foundation

/// A type that is `CounterexampleProviding` is a type that provides deliberately incorrect or corrupted example data.
///
/// The documentation of the type that implements this protocol should describe in what way the data is incorrect or
/// corrupted.
internal protocol CounterexampleProviding: ExampleProviding {
    
    /// The type of the counterexample data that the implementing type provides.
    associatedtype U
    // swiftlint:disable:previous type_name
    
    /// The counterexample data.
    static var counterexample: U { get }
    
}
