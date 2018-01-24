//
//  ItemFriendTableViewCell.swift
//  SymondsStudentApp
//
//  Created by Søren Mortensen on 24/01/2018.
//  Copyright © 2018 Søren Mortensen, George Taylor. All rights reserved.
//

import UIKit

/// Displays the name of a single friend who shares an item with the user.
class ItemFriendTableViewCell: UITableViewCell {
    
    // MARK: - IBOutlets
    
    /// A label containing the name of the friend.
    @IBOutlet weak var friendName: UILabel!
    
    // MARK: - UITableViewCell
    
    /// :nodoc:
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            self.setSelected(false, animated: true)
        }
    }
    
}
