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
    private var attrToProperName: [String: String] = [String: String]()
    private var properNameToAttr: [String: String] = [String: String]()
    
    private var selectedAttractions: [String] = [String]()
    
    func setAttractions(incAttractions: [String]) {
        self.attractions = incAttractions
    }
    
    func setAttrToProperName(incAttrTranslation: [String: String]) {
        self.attrToProperName = incAttrTranslation
    }
    
    func setProperNameToAttr(incReverseTranslation: [String: String]) {
        self.properNameToAttr = incReverseTranslation
    }
    
    func getSelectedAttractions() -> [String] {
        return self.selectedAttractions
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.allowsMultipleSelection = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

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
        
        let attraction = attrToProperName[attractions[indexPath.row]]
        
        // Check if this row had been selected, add a checkmark if it was selected before
        if (selectedAttractions.contains(attractions[indexPath.row])) {
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
        
        // Set checkmark for row and add this attraction to the array of selected attractions
        cell.accessoryType = .checkmark
        selectedAttractions.append(attractions[indexPath.row])
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? AttractionsTableViewCell else {
            fatalError("Cell wasn't AttractionsTableViewCell")
        }
        
        // Remove checkmark from row and remove this attraction from array of selected attractions
        cell.accessoryType = .none
        if let index = selectedAttractions.index(of: properNameToAttr[cell.attractionName.text!]!) {
            selectedAttractions.remove(at: index)
        }
    }
}
