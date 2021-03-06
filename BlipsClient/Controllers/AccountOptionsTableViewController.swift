//
//  AccountOptionsTableViewController.swift
//  BlipsClient
//
//  Created by Cyrus Sadeghi on 2018-02-22.
//  Copyright © 2018 Cyrus Sadeghi. All rights reserved.
//

import UIKit

class AccountOptionsTableViewController: UITableViewController, UserAccountObserver {
    var account: User!

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func userLoggedIn(account: User) {
        self.account = account
    }
    
    func userLoggedOut() {
        self.account = nil
    }
    
    func guestReplaced(guestQueried: Bool) {
        self.account = nil
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let queryOptionsVC = segue.destination as? QueryOptionsTableViewController {
            var attractionHistoryCount = account.getAttractionHistoryCount()
            
            if attractionHistoryCount > 10 {
                attractionHistoryCount = 10
            }
            
            queryOptionsVC.addQueryOptionsObserver(observer: account)
            queryOptionsVC.attractionHistoryCount = attractionHistoryCount
            queryOptionsVC.queryOptions = account.autoQueryOptions
        }
        
        if let savedBlipsVC = segue.destination as? SavedBlipTableViewController {
            savedBlipsVC.addObserver(observer: account)
            savedBlipsVC.savedBlips = account.savedBlips
        }
    }
}
