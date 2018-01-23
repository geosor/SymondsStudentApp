//
//  StudentTimetableService.swift
//  SSACore
//
//  Created by Søren Mortensen on 21/01/2018.
//  Copyright © 2018 Søren Mortensen, George Taylor. All rights reserved.
//

import Foundation

/// Service that provides details about a student's timetable.
public final class StudentTimetableService {
    
    // MARK: - Properties
    
    /// An access token, used for authentication with the user service.
    private let accessToken: LoginService.AccessToken
    
    // MARK: - Initialisers
    
    /// Initialises an instance of StudentTimetableService with an access token.
    ///
    /// - Parameter accessToken: The user's access token, used for authentication with the data service API.
    public init(accessToken: LoginService.AccessToken) {
        self.accessToken = accessToken
    }
    
    // MARK: - Methods
    
    /// Makes a request for the user's timetable for this week from the data service.
    ///
    /// - Parameter completion: Completion handler to receive the result of the request and handle any errors or extract
    ///                         data as appropriate.
    public func makeRequest(completion: @escaping (DataService.Result<Timetable>) -> Void) {
        let monday = Day.dateThisWeek(from: .monday)
        let startTimestamp = String(UInt64(floor(monday.timeIntervalSince1970)))
        
        let saturday = Day.dateThisWeek(from: .saturday)
        let endTimestamp = String(UInt64(floor(saturday.timeIntervalSince1970)))
        
        let parameters = [
            "start": startTimestamp,
            "end": endTimestamp
        ]
        
        DataService(accessToken: self.accessToken)
            .call(.studentTimetable, parameters: parameters, completion: completion)
    }
    
}
