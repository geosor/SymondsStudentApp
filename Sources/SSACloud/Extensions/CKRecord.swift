//
//  CKRecord.swift
//  SSACloud
//
//  Created by Søren Mortensen on 26/01/2018.
//  Copyright © 2018 Søren Mortensen, George Taylor. All rights reserved.
//

import CloudKit

extension CKRecord {
    
    /// Attempts to load a value of type `type` and name `name` from `self`. For example:
    ///
    /// ```
    /// let record = CKRecord(recordType: "foo", recordID: "bar")
    /// record["name"] = "Baz Qux" as NSString
    /// record["email"] = "quux@corge.grault" as NSString
    ///
    /// do {
    ///     let name = try record.loadValue(ofType: String.self, named: "name")
    ///     let email = try record.loadValue(ofType: Int.self, named: "email") // throws an error
    /// } catch let error {
    ///     // error is RecordError.invalidData(fieldName: "email")
    /// }
    /// ```
    public func loadValue<T>(ofType type: T.Type, named name: String) throws -> T {
        guard let value = self[name] as? T else {
            throw RecordError.invalidData(fieldName: name)
        }
        
        return value
    }
    
}
