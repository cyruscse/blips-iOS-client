//
//  SavedBlipTableViewController.swift
//  BlipsClient
//
//  Created by Cyrus Sadeghi on 2018-02-25.
//  Copyright © 2018 Cyrus Sadeghi. All rights reserved.
//

import UIKit

class SavedBlipTableViewController: UITableViewController {
    var savedBlips: [Blip]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rowHeight = 44.0
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedBlips.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "BlipTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? BlipTableViewCell else {
            fatalError("Dequeued cell wasn't BlipTableViewCell")
        }
        
        if savedBlips.count == 0 {
            //self.hideTableView() - hide table and display background message instead
            return UITableViewCell()
        }
        
        let blip = savedBlips[indexPath.row]
        
        cell.selectionStyle = .none
        cell.blipName.text = blip.title
        cell.blipType.text = blip.attractionType
        cell.typeImage.sd_setImage(with: blip.icon) { (_, _, _, _) in }
        
        return cell
    }
}
