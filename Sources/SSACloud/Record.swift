//
//  Record.swift
//  SSACloud
//
//  Created by Søren Mortensen on 26/01/2018.
//  Copyright © 2018 Søren Mortensen, George Taylor. All rights reserved.
//

import Foundation
import CloudKit

/// A `Record` is any type that can be stored as a corresponding record type in CloudKit.
public protocol Record {
    
    /// The record ID for `self`.
    ///
    /// This should be consistent across instances of `Self` that represent the same `CKRecord`.
    var recordID: CKRecordID { get }
    
    /// Creates a new `Record` from the corresponding `CKRecord` for `Self`.
    init(record: CKRecord) throws
    
    /// Creates and returns a `CKRecord` from the data in `self`.
    func createRecord() -> CKRecord
    
    /// The record type that represents `Self` in CloudKit.
    static var recordType: String { get }
}

/// The completion handler type for CloudKit-related operations performed by `Record` types.
public typealias RecordCompletion<T> = (RecordResult<T>) -> Void

/// Indicates the result of a CloudKit-related operation performed by a `Record` type.
public enum RecordResult<T> {
    
    /// The operation was successful.
    case success(T)
    
    /// The operation failed. The error describes the reason why.
    case error(RecordError)
}

/// Indicates the reason for failure of a CloudKit-related operation performed by a `Record` type.
public enum RecordError: Error {
    
    /// An unexpected error occurred. If an `Error` is available, it is provided.
    case unexpected(Error?)
}
