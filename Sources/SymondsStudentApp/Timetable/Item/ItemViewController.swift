//
//  ItemViewController.swift
//  SymondsStudentApp
//
//  Created by Søren Mortensen on 24/01/2018.
//  Copyright © 2018 Søren Mortensen, George Taylor. All rights reserved.
//

import UIKit
import SSACore

/// Displays information about a specific timetable item.
class ItemViewController: UITableViewController {
    
    // MARK: - Properties
    
    /// The item whose details are being displayed.
    var item: Timetable.Item!
    
    /// All `Friend`s of the primary user who share `lesson` with the user.
    var freeFriends: [SSACore.Friend] {
        // Return all the friends who share the current lesson.
//        return PrimaryUser.loggedIn.matchingFriends(
//            for: lesson.id,
//            from: lesson.start,
//            to: lesson.end)
        return []
    }
    
    // MARK: - UITableViewController
    
    /// :nodoc:
    override func numberOfSections(in tableView: UITableView) -> Int {
        if !freeFriends.isEmpty {
            // If there are any free friends, then there should be two sections,
            // because the second section contains the free friends.
            return 2
        } else {
            // Otherwise, only the details are being displayed.
            return 1
        }
    }
    
    /// :nodoc:
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            // There are always the same three rows in the first section.
            return 3
        } else {
            // There is one cell per free friend in the second section.
            return freeFriends.count
        }
    }
    
    /// :nodoc:
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            // The title of the first section is "Details"
            return "Details"
        } else {
            // The title of the second section is "Friends". There are only ever
            // going to be a maximum of two sections, so we're safe to use an
            // else clause here.
            return "Friends"
        }
    }
    
    /// :nodoc:
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // Switch based on the section and row of the index path.
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            // This is the first row of the first section.
            // The very first cell is always 86 points tall.
            return 86
        default:
            // The others are always 44.
            return 44
        }
    }
    
    /// :nodoc:
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // swiftlint:disable force_cast
        
        // The cell we want depends on the section and row.
        switch (section: indexPath.section, row: indexPath.row) {
        case (section: 0, row: 0):
            // The first row of the first section.
            // This cell contains basic details about the lesson: title,
            // date, and time range.
            
            // Dequeue a cell so we can customise it.
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "Details"
                ) as! ItemDetailsTableViewCell
            
            // Set the text in the title, date, and time range labels.
            cell.title.text = item.title
            cell.date.text = item.dateLabel
            cell.timeRange.text = item.timeRangeLabel
            
            // If the lesson is cancelled, then use the time range label
            // to indicate that to the user.
            if item.isCancelled {
                // swiftlint:disable:next colon
                cell.timeRange.textColor = #colorLiteral(red:1, green:0.1491314173, blue:0, alpha:1)
                cell.timeRange.text = "Cancelled"
            }
            
            return cell
        case (section: 0, row: 1):
            // The second row of the first section displays the lesson's
            // room number.
            
            // Dequeue a cell so we can customise it.
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "Room"
                ) as! ItemRoomTableViewCell
            
            // Set the text in the room number label.
            cell.roomNumber.text = item.room ?? "None"
            
            // If the room has been changed, then alert the user by
            // setting the text colour of the label to red.
            if item.isRoomChange {
                // swiftlint:disable:next colon
                cell.roomNumber.textColor = #colorLiteral(red:1, green:0.1491314173, blue:0, alpha:1)
            }
            
            return cell
        case (section: 0, row: 2):
            // The third row of the first section displays the name of
            // the staff member teaching the lesson.
            
            // Dequeue a cell so we can customise it.
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "Staff"
                ) as! ItemStaffTableViewCell
            
            // Set the text in the staff name label.
            // This line uses the nil-coalescing operator, ??, to set the
            // value in the label to "None" if lesson.staff is nil.
            cell.staffName.text = item.staff ?? "None"
            
            return cell
        case (section: 1, let row):
            // Any cell in the second section is a free friend.
            
            // Dequeue a cell so we can customise it.
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "Friend"
                ) as! ItemFriendTableViewCell
            
            // Set the text in the friend name label, using the free friend
            // at index `row`.
            cell.friendName.text = freeFriends[row].name
            
            return cell
        default:
            // This case should never be reached, so we just return an empty
            // UITableViewCell.
            return UITableViewCell()
        }
        
        // swiftlint:enable force_cast
    }
    
}
