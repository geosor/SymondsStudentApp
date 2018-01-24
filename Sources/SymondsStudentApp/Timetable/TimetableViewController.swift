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
    var timetable: Timetable?
//    {
//        do {
//            let decoder = JSONDecoder()
//            return try decoder.decode([TimetableItem].self, from: TimetableItem.example)
//        } catch DecodingError.dataCorrupted(let context) {
//            print("Unable to decode example timetable items due to corrupted data. Context: \(context)")
//            return []
//        } catch {
//            print("Unable to decode example timetable items. Error: \(error).")
//            return []
//        }
//    }
    
    @objc func updateTimetable() {
        guard let accessToken = PrimaryUser.loggedIn?.authenticator.accessToken else {
            self.tableView.refreshControl?.endRefreshing()
            return
        }
        
        StudentTimetableService(accessToken: accessToken).makeRequest { result in
            switch result {
            case .success(let timetable):
                self.timetable = timetable
            case .error(let error):
                print(error)
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.tableView.refreshControl?.endRefreshing()
            }
        }
    }
    
    // MARK: - UITableViewController
    
    /// :nodoc:
    override func numberOfSections(in tableView: UITableView) -> Int {
        guard let timetable = self.timetable else {
            return 0
        }
        
        let count = Day.week.filter { timetable.itemsOccur(in: .normalItems, on: $0) }.count
        return count
    }
    
    /// :nodoc:
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let timetable = self.timetable else { return 0 }
        
        return timetable[.normalItems, section].count
    }
    
    /// :nodoc:
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "timetable") as? TimetableTableViewCell else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        guard let timetable = self.timetable else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        cell.updateContents(toMatch: timetable[.normalItems, indexPath.section][indexPath.row])
        
        return cell
    }
    
    /// :nodoc:
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.timetable?.normalItemDays[section].description
    }
    
    // MARK: - UIViewController
    
    /// :nodoc:
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(updateTimetable), for: .valueChanged)
        
        self.tableView.refreshControl = refreshControl
        self.tableView.refreshControl?.layoutIfNeeded()
        
        self.tableView.refreshControl?.beginRefreshing()
        self.updateTimetable()
    }
    
    /// :nodoc:
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
