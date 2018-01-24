//
//  ItemDetailsTableViewCell.swift
//  SymondsStudentApp
//
//  Created by Søren Mortensen on 24/01/2018.
//  Copyright © 2018 Søren Mortensen, George Taylor. All rights reserved.
//

import UIKit
import SSACore

/// Displays basic details about an item, including the title, time and date.
class ItemDetailsTableViewCell: UITableViewCell {
    
    // MARK: - IBOutlets
    
    /// A label containing the title of the item.
    @IBOutlet weak var title: UILabel!
    
    /// A label containing the date of the item.
    @IBOutlet weak var date: UILabel!
    
    /// A label containing the time range of the item.
    @IBOutlet weak var timeRange: UILabel!
    
    // MARK: - UITableViewCell
    
    /// :nodoc:
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            self.setSelected(false, animated: false)
        }
    }
    
}
