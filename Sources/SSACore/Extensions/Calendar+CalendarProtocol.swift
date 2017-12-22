//
//  Calendar+CalendarProtocol.swift
//  SSACore
//
//  Created by Søren Mortensen on 16/12/2017.
//  Copyright © 2017 Søren Mortensen, George Taylor. All rights reserved.
//

import Foundation

extension Calendar: CalendarProtocol {
    
    func today() -> Date {
        return Date()
    }
    
}
