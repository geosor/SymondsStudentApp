//
//  TimetableViewController.swift
//  SymondsStudentApp
//
//  Created by Søren Mortensen on 27/11/2017.
//  Copyright © 2017 Søren Mortensen, George Taylor. All rights reserved.
//

import UIKit
import SSACore

class TimetableViewController: UITableViewController {
    
    /// The items being displayed in the view controller.
    var items: [TimetableItem] {
        do {
            let decoder = JSONDecoder()
            return try decoder.decode([TimetableItem].self, from: TimetableItem.example)
        } catch DecodingError.dataCorrupted(let context) {
            print("Unable to decode example timetable items due to corrupted data. Context: \(context)")
            return []
        } catch {
            print("Unable to decode example timetable items. Error: \(error).")
            return []
        }
    }
    
    // MARK: - UITableViewController
    
    /// :nodoc:
    override func numberOfSections(in tableView: UITableView) -> Int {
        let days: Set<Day> = self.items
            .flatMap { $0.day }
            .reduce(Set()) { acc, next in
                if !acc.contains(next) {
                    return acc.union([next])
                } else {
                    return acc
                }
            }
        
        return days.count
    }
    
    /// :nodoc:
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    /// :nodoc:
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "timetable") as? TimetableTableViewCell else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        cell.updateContents(toMatch: self.items[indexPath.row])
        
        return cell
    }
    
    // MARK: - UIViewController
    
    /// :nodoc:
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    /// :nodoc:
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
