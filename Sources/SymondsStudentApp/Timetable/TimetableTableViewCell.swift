//
//  TimetableTableViewCell.swift
//  SymondsStudentApp
//
//  Created by Søren Mortensen on 27/11/2017.
//  Copyright © 2017 Søren Mortensen, George Taylor. All rights reserved.
//

import UIKit

/// Timetable table view cells display the details of a specific `TimetableItem` in the timetable table view.
class TimetableTableViewCell: UITableViewCell {
    
    /// Label that displays the start time of this item.
    @IBOutlet weak var startTimeLabel: UILabel!
    
    /// Label that displays the end time of this item.
    @IBOutlet weak var endTimeLabel: UILabel!
    
    /// Label that displays the title of this item.
    @IBOutlet weak var titleLabel: UILabel!
    
    /// Label that displays the room number of this item.
    @IBOutlet weak var roomLabel: UILabel!
    
    /// View that displays a bar of colour to indicate what type of item this is.
    @IBOutlet weak var colourBar: UIView!
    
    /// Updates the contents of this cell to match the details in the given `TimetableItem`.
    ///
    /// - Parameter item: The timetable item to use as the basis for the update.
    func updateContents(toMatch item: TimetableItem) {
        self.startTimeLabel.text = item.startTimeLabel
        self.endTimeLabel.text = item.endTimeLabel
        self.titleLabel.text = item.title
        self.roomLabel.text = item.room
    }
    
    // MARK: - UITableViewCell
    
    /// :nodoc:
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // If the cell has been asked to select itself, now call again to deselect, or the cell gets stuck in a selected
        // state.
        if selected {
            self.setSelected(false, animated: true)
        }
    }
    
}
