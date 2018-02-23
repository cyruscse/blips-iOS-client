//
//  QueryOptionsTableViewController.swift
//  BlipsClient
//
//  Created by Cyrus Sadeghi on 2018-02-23.
//  Copyright © 2018 Cyrus Sadeghi. All rights reserved.
//

import UIKit

class QueryOptionsTableViewController: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Autoquery Options"
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Section 0 is Automatic Query global enable/disable (currently has 1 row)
        // Section 1 is Attraction Type number to select (currently has 1 row)
        // Section 2 is Lookup Attributes (currently has 3 rows)
        if section == 2 {
            return 3
        }
        
        return 1
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
