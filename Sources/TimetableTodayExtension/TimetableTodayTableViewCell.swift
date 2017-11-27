//
//  TimetableTodayTableViewCell.swift
//  FreeRoomsTodayExtension
//
//  Created by Søren Mortensen on 25/11/2017.
//  Copyright © 2017 Søren Mortensen, George Taylor. All rights reserved.
//

import UIKit

class TimetableTodayTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if selected {
            self.setSelected(false, animated: true)
        }
    }

}
