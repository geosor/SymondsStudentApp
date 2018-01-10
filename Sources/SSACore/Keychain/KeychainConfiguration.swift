//
//  Copyright (C) 2016 Apple Inc. All Rights Reserved.
//  See LICENSE-Keychain file for this sample’s licensing information
//
//  Abstract:
//  A simple struct that defines the service and access group to be used by the sample apps.
//
//  Modified on 10 January 2018 by Søren Mortensen.
//

import Foundation

/// :nodoc:
public struct KeychainConfiguration {
    
    /// :nodoc:
    let serviceName: String
    
    /// Specifying an access group to use with `KeychainPasswordItem` instances will create items shared accross both
    /// apps.
    ///
    /// For information on App ID prefixes, see:
    /// https://developer.apple.com/library/ios/documentation/General/Conceptual/DevPedia-CocoaCore/AppID.html
    /// and https://developer.apple.com/library/ios/technotes/tn2311/_index.html.
    ///
    /// Not specifying an access group to use with `KeychainPasswordItem` instances will create items specific to each
    /// app.
    let accessGroup: String?
    
    /// Creates an instance of `KeychainConfiguration` with a specified service name and access group.
    ///
    /// - Parameters:
    ///   - serviceName: The service name.
    ///   - accessGroup: The access group. The default value of this parameter is `nil`.
    init(serviceName: String, accessGroup: String? = nil) {
        self.serviceName = serviceName
        self.accessGroup = accessGroup
    }
    
}
