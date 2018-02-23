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
