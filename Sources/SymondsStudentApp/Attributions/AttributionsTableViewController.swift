//
//  AttributionsTableViewController.swift
//  SymondsStudentApp
//
//  Created by Søren Mortensen on 21/01/2018.
//  Copyright © 2018 Søren Mortensen, George Taylor. All rights reserved.
//

import UIKit
import SafariServices

class AttributionsTableViewController: UITableViewController {
    
    // MARK: - UITableViewController
    
    /// :nodoc:
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    /// :nodoc:
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Attributions.attributions.count
    }
    
    /// :nodoc:
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // swiftlint:disable:next force_cast
        let cell = tableView.dequeueReusableCell(withIdentifier: "attribution") as! AttributionTableViewCell
        
        // Fill in the details.
        cell.fill(from: Attributions.attributions[indexPath.row])
        
        return cell
    }
    
    /// :nodoc:
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let link = Attributions.attributions[indexPath.row].link
        let safari = SFSafariViewController(url: link)
        self.present(safari, animated: true, completion: nil)
    }
    
}
