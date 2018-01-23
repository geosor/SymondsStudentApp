//
//  DataService.swift
//  SSACore
//
//  Created by Søren Mortensen on 21/01/2018.
//  Copyright © 2018 Søren Mortensen, George Taylor. All rights reserved.
//

import Foundation

/// Convenience implementation of general-form interaction with the data service.
public struct DataService {
    
    /// The user's access token.
    private let accessToken: LoginService.AccessToken
    
    /// Initialises a new instance of `DataService` with the user's access token.
    ///
    /// - Parameter accessToken: The user's access token.
    internal init(accessToken: LoginService.AccessToken) {
        self.accessToken = accessToken
    }
    
    /// Makes an API call to the specified service with the given parameters, and passes back the result to the given
    /// completion handler.2
    ///
    /// - Parameters:
    ///   - service: The service to make a request to.
    ///   - parameters: The parameters of the request.
    ///   - completion: The completion handler.
    internal func call<T>(_ service: DataService.Service,
                          parameters: [String: String],
                          completion: @escaping (DataService.Result<T>) -> Void) where T: Decodable {
        // Take the parameters and turn them into query items. Each (key, value) pair in the dictionary represents the
        // key and value of a URL query item.
        let queryItems = parameters.map { key, value in
            return URLQueryItem(name: key, value: value)
        }
        
        // Compose a URL by combining the specific URL endpoint for the service requested with the query we just
        // created.
        let components = URLComponents(string: DataService.apiURLString(for: service), queryItems: queryItems)!
        
        // Create a URL request.
        var request = URLRequest(url: components.url!)
        
        // The request needs to contain the user's access token in the header.
        request.addValue("Bearer \(self.accessToken.accessToken)", forHTTPHeaderField: "Authorization")
        
        // Create a data task.
        URLSession.shared.dataTask(with: request) { data, response, error in
            // Note: in this version of this method, as opposed to previous iterations, we are checking the response
            // first, because it seems that an incorrect HTTP status code gives more information about what went wrong
            // than there simply being no data. We'll see how well that works.
            
            // Check that the response is an `HTTPURLResponse` and not just a `URLResponse` or `nil`.
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.error(.incompleteResponse(response)))
                return
            }
            
            // If the HTTP status code is not 200, it indicates an error.
            guard httpResponse.statusCode == 200 else {
                completion(.error(.httpStatus(httpResponse.statusCode)))
                return
            }
            
            // Check to make sure we received some data.
            guard let data = data, error == nil else {
                if let error = error {
                    // If we didn't receive any data, but we got an error describing why, let's pass the error on.
                    completion(.error(.unexpected(error)))
                } else {
                    // Otherwise, all we can say is that we didn't get any data.
                    completion(.error(.noDataReceived))
                }
                return
            }
            
            do {
                // Try to decode the type that we were told to decode.
                let decoded = try JSONDecoder().decode(T.self, from: data)
                // It succeeded! Call the completion handler.
                completion(.success(decoded))
            } catch let error {
                // It failed... pass the buck to the caller and drop it like a hot potato. This is their problem.
                // If they want to take the data and try to figure it out, they can do that. It's no skin off my back.
                completion(.error(.invalidData(data, error)))
            }
        }.resume()
    }
    
    /// The URL where requests for data from the various `Service`s (e.g. `.studentTimetable`, `.find`) are sent.
    private static let apiURL = "https://data.psc.ac.uk/api"
    
    /// Creates an absolute URL, in `String` form, for the specified service.
    ///
    /// - Parameter service: The service to create a URL for.
    /// - Returns: The absolute URL string for the service.
    private static func apiURLString(for service: DataService.Service) -> String {
        return "\(DataService.apiURL)/\(service.rawValue)"
    }
    
    /// A service provided by the Symonds data service, such as User or Student Timetable.
    internal enum Service: String {
        case user = "user"
        case studentTimetable = "timetable"
        case find = "find"
        case roomTimetable = "roomtimetable"
    }
    
    /// The result of a data service operation.
    public enum Result<T> {
        case success(T)
        case error(DataService.Error)
    }
    
    /// Errors that might arise during data service operations.
    public enum Error: Swift.Error {
        case noDataReceived
        case incompleteResponse(URLResponse?)
        case httpStatus(Int)
        case invalidData(Data, Swift.Error)
        case unexpected(Swift.Error)
    }
    
}
