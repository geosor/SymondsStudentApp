//
//  PrimaryUser.swift
//  SSACloud
//
//  Created by Søren Mortensen on 26/01/2018.
//  Copyright © 2018 Søren Mortensen, George Taylor. All rights reserved.
//

import CloudKit
import SSACore

/// Implements `RecordSaveable` for `PrimaryUser`.
extension PrimaryUser: RecordSaveable {
    
    // MARK: - Record
    
    /// :nodoc:
    public var recordID: CKRecordID {
        return CKRecordID(recordName: "\(self.id)")
    }
    
    /// :nodoc:
    public func saveData(in record: CKRecord) {
        record["forename"] = self.forename as NSString
        record["surname"] = self.surname as NSString
        record["username"] = self.username as NSString
        record["name"] = self.name as NSString
        record["email"] = self.email as NSString
    }
    
    /// :nodoc:
    public func save(in database: CKDatabase, completion: @escaping (RecordResult<CKRecord>) -> Void) {
        CKContainer.default().fetchUserRecordID { [weak self] recordID, error in
            guard let recordID = recordID else {
                if let ckError = error as? CKError {
                    completion(.error(.ckError(ckError)))
                } else {
                    completion(.error(.unexpected(error)))
                }
                
                return
            }
            
            database.fetch(withRecordID: recordID) { [weak self] record, error in
                guard let record = record else {
                    if let ckError = error as? CKError {
                        completion(.error(.ckError(ckError)))
                    } else {
                        completion(.error(.unexpected(error)))
                    }
                    
                    return
                }
                
                self?.saveData(in: record)
                database.save(record) { record, error in
                    guard let record = record else {
                        if let ckError = error as? CKError {
                            completion(.error(.ckError(ckError)))
                        } else {
                            completion(.error(.unexpected(error)))
                        }
                        
                        return
                    }
                    
                    completion(.success(record))
                }
            }
        }
    }
    
    /// :nodoc:
    public static var recordType: String {
        return "Users"
    }
    
}
