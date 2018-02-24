//
//  RecordRepresentable.swift
//  SSACloud
//
//  Created by Søren Mortensen on 26/01/2018.
//  Copyright © 2018 Søren Mortensen, George Taylor. All rights reserved.
//

import CloudKit

// MARK: RecordRepresentable

/// `RecordRepresentable` types are types that are both saveable to `CKRecord`s and able to be instantiated fully from
/// `CKRecords`. In other words, a type that is `RecordRepresentable` can be fully represented by a record in CloudKit.
public typealias RecordRepresentable = RecordSaveable & RecordLoadable

// MARK: - RecordSaveable

/// `RecordSaveable` types can store details about themselves in CloudKit `CKRecord`s, but cannot necessarily be fully
/// instantiated from them.
public protocol RecordSaveable {
    
    /// The record ID for `self`.
    ///
    /// This must be consistent across instances of `Self` that represent the same `CKRecord`.
    var recordID: CKRecordID { get }
    
    /// Creates and returns a `CKRecord` from the data in `self`.
    func createRecord() -> CKRecord
    
    /// Fills in `record` with details from `self`.
    func saveData(in record: CKRecord)
    
    /// Creates and saves a new `CKRecord` or updates the existing record in `database` with details from `self`.
    ///
    /// Note that, as described in the documentation for `CloudKit.CKDatabase.save(_:completionHandler:)`, this
    /// operation will overwrite an existing record if and only if the existing record is older than the one that is
    /// that is being saved.
    ///
    /// - Parameter completion: Completion handler for when the CloudKit request finishes. This completion handler
    ///                         should pass back the new record as returned by CloudKit in the event of success.
    /// - SeeAlso: `CloudKit.CKDatabase.save(_:completionHandler:)`.
    func save(in database: CKDatabase, completion: @escaping RecordCompletion<CKRecord>)
    
    /// The record type that `Self` can save its details to.
    static var recordType: String { get }
}

// MARK: Default Implementations

public extension RecordSaveable {
    
    /// Default implementation of `createRecord()` that creates a new record that is filled in with details from `self`
    /// by calling `self.saveData(in:)`.
    public func createRecord() -> CKRecord {
        let record = CKRecord(recordType: Self.recordType, recordID: self.recordID)
        self.saveData(in: record)
        return record
    }
    
    /// Default implementation of `save(in:completion:)`.
    public func save(in database: CKDatabase, completion: @escaping RecordCompletion<CKRecord>) {
        database.save(self.createRecord()) { record, error in
            switch record {
            case .some(let record):
                completion(.success(record))
            case .none:
                if let ckError = error as? CKError {
                    completion(.error(.ckError(ckError)))
                } else {
                    completion(.error(.unexpected(error)))
                }
            }
        }
    }
    
}

// MARK: - RecordLoadable

/// `RecordLoadable` types can be fully instantiated from `CKRecord`s, but cannot necessarily be saved to them.
///
/// The unusual nature of this pair of properties means that `RecordLoadable` conformance (i.e. on its own, not paired
/// with `RecordSaveable` or declared as `RecordRepresentable`) should be used to allow a type to be instantiated from a
/// `CKRecord` that normally represents a different type. For example:
///
/// ```
/// /// `User` is `RecordSaveable`, so it can be saved to
/// /// `CKRecord`s.
/// struct User: RecordSaveable {
///     let id: String
///     let username: String
///     var score: Int
///
///     var recordID: CKRecordID {
///         return CKRecordID(recordName: self.id)
///     }
///
///     func saveData(in record: CKRecord) {
///         record["username"] = self.username as NSString
///         record["score"] = NSNumber(value: self.score)
///     }
///
///     static var recordType: String { return "User" }
/// }
///
/// /// `AnonymisedUser` represents a `User`, but is used
/// /// to show a user details about another user without
/// /// revealing their username.
/// struct AnonymisedUser: RecordLoadable {
///     let id: String
///     let score: Int
///
///     init(from record: CKRecord) throws {
///         let actual = record.recordType
///         let expected = AnonymisedUser.recordType
///         guard actual == expected else {
///             throw RecordError.wrongRecordType(
///                 actual: actual,
///                 expected: expected
///             )
///         }
///
///         self.id = record.recordID.recordName
///
///         guard let score = record["score"]
///             as? Int else {
///                 throw RecordError.invalidData(
///                     fieldName: "score"
///                 )
///         }
///
///     }
///
///     /// `AnonymisedUser` uses the same record type as
///     /// `User` because it loads from the same records.
///     static var recordType: String { return "User" }
/// }
/// ```
public protocol RecordLoadable {
    
    /// Instantiates a new instance of `Self` from the data contained in `record`.
    ///
    /// - Throws: Errors of type `RecordError` to indicate why loading the data failed.
    init(from record: CKRecord) throws
    
    /// The record type that `Self` can be loaded from.
    static var recordType: String { get }
}

// MARK: - Errors, Results & Completions

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
    
    /// The field named `fieldName` contained invalid data.
    case invalidData(fieldName: String)
    
    /// The provided record is of the wrong record type, `actual`, when it should have been `expected`.
    case wrongRecordType(actual: String, expected: String)
    
    /// An error occurred that was indicated by the provided `CKError` instance.
    case ckError(CKError)
    
    /// An unexpected error occurred. If an `Error` is available, it is provided.
    case unexpected(Error?)
}
