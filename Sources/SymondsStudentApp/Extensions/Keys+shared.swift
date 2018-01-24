//
//  Keys+shared.swift
//  SymondsStudentApp
//
//  Created by Søren Mortensen on 24/01/2018.
//  Copyright © 2018 Søren Mortensen, George Taylor. All rights reserved.
//

import Foundation
import SSACore

extension Keys {
    
    /// The keys used for the SymondsStudentApp.
    internal static var shared: Keys = {
        do {
            guard let url = Bundle.main.url(forResource: "keys", withExtension: "json") else {
                throw NSError(domain: "com.sorenmortensen.SymondsStudentApp", code: 314159, userInfo: nil)
            }
            
            let fileData = try Data(contentsOf: url)
            return try JSONDecoder().decode(Keys.self, from: fileData)
        } catch {
            fatalError("Error while settings keys: \(error)")
        }
    }()
    
}
