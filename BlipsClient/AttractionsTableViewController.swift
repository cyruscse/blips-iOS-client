//
//  AttractionsTableViewController.swift
//  BlipsClient
//
//  Created by Cyrus Sadeghi on 2018-01-11.
//  Copyright © 2018 Cyrus Sadeghi. All rights reserved.
//

import UIKit

class AttractionsTableViewController: UITableViewController {
    private var attractions: [String] = [String]()
    private var selectedAttractions: [String] = [String]()
    
    func setAttractions(incAttractions: [String]) {
        self.attractions = incAttractions
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.allowsMultipleSelection = true
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return attractions.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "AttractionsTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? AttractionsTableViewCell else {
            fatalError("Dequeued cell wasn't AttractionsTableViewCell")
        }
        
        let attraction = attractions[indexPath.row]
        
        if (selectedAttractions.contains(attraction)) {
            cell.accessoryType = .checkmark
        }
        else {
            cell.accessoryType = cell.isSelected ?.checkmark : .none
        }
        
        cell.selectionStyle = .none
        cell.attractionName.text = attraction

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? AttractionsTableViewCell else {
            fatalError("Cell wasn't AttractionsTableViewCell")
        }
        
        cell.accessoryType = .checkmark
        selectedAttractions.append(attractions[indexPath.row])
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? AttractionsTableViewCell else {
            fatalError("Cell wasn't AttractionsTableViewCell")
        }
        
        cell.accessoryType = .none
        if let index = selectedAttractions.index(of: cell.attractionName.text!) {
            selectedAttractions.remove(at: index)
        }
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}
