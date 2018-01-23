//
//  AttributionTableViewCell.swift
//  SymondsStudentApp
//
//  Created by Søren Mortensen on 21/01/2018.
//  Copyright © 2018 Søren Mortensen, George Taylor. All rights reserved.
//

import UIKit

class AttributionTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    /// Label that displays the name.
    @IBOutlet weak var nameLabel: UILabel!
    
    /// Label that displays the attribution.
    @IBOutlet weak var attributionLabel: UILabel!
    
    // MARK: - Methods
    
    /// Fills in the labels on this cell with the details from an `Attribution`.
    ///
    /// - Parameter attribution: The attribution containing the details to fill in to the labels.
    func fill(from attribution: Attribution) {
        self.nameLabel.text = attribution.name
        self.attributionLabel.text = attribution.attribution
    }
    
    // MARK: - UITableViewCell
    
    /// :nodoc:
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // If we don't do this, cells never deselect after being selected.
        if selected {
            self.setSelected(false, animated: true)
        }
    }
    
}
