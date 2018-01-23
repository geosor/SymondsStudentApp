//
//  Attributions.swift
//  SymondsStudentApp
//
//  Created by Søren Mortensen on 16/12/2017.
//  Copyright © 2017 Søren Mortensen, George Taylor. All rights reserved.
//

import Foundation

/// A class to hold attributions to content creators whose content has been used in the app.
class Attributions {
    
    /// The attributions.
    static let attributions: [Attribution] = [
        Attribution(name: "App icon (calendar)",
                    attribution: """
                    Made by Freepik (www.freepik.com) from Flaticon (www.flaticon.com). Licensed by Creative Commons \
                    BY 3.0 (www.creativecommons.org/licenses/by/3.0).
                    """,
                    link: URL(string: "http://www.freepik.com")!),
        Attribution(name: "Tab icons: calendar, users, settings",
                    attribution: """
                    Made by Madebyoliver (www.flaticon.com/authors/madebyoliver) from Flaticon (www.flaticon.com). \
                    Licensed by Creative Commons BY 3.0 (www.creativecommons.org/licenses/by/3.0).
                    """,
                    link: URL(string: "http://www.flaticon.com/authors/madebyoliver")!),
        Attribution(name: "Tab icon: work station",
                    attribution: """
                    Made by Eucalyp (www.flaticon.com/authors/eucalyp) from Flaticon (www.flaticon.com). Licensed by \
                    Creative Commons BY 3.0 (www.creativecommons.org/licenses/by/3.0).
                    """,
                    link: URL(string: "http://www.flaticon.com/authors/eucalyp")!)
    ]
    
}

/// An attribution of a particular item.
struct Attribution {
    
    /// The name of the item that is being attributed.
    let name: String
    
    /// The attribution itself.
    let attribution: String
    
    /// A link to the source of the item.
    let link: URL
    
}
