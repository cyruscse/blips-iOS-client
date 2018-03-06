//
//  AttractionsTableViewController.swift
//  BlipsClient
//
//  Created by Cyrus Sadeghi on 2018-01-11.
//  Copyright © 2018 Cyrus Sadeghi. All rights reserved.
//

import UIKit

class AttractionsTableViewController: UITableViewController {
    private var prioritySortedAttractions: [String] = [String]()
    private var attrToProperName: [String: String] = [String: String]()
    private var properNameToAttr: [String: String] = [String: String]()
    private var selectedAttractions: [String] = [String]()
    private var observers: [AttractionTableObserver] = [AttractionTableObserver]()
    private var userTypeQueryCount: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.allowsMultipleSelection = true
        tableView.rowHeight = 44.0
        navigationItem.title = "Lookup Types"
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        if userTypeQueryCount != 0 {
            return 2
        }
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if userTypeQueryCount == 0 {
            return nil
        }
        
        if section == 0 {
            return "Suggested Types"
        }
        
        return "All Types"
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if userTypeQueryCount > 0 {
            if section == 0 {
                return userTypeQueryCount
            }
            
            return prioritySortedAttractions.count - userTypeQueryCount
        }
 
        return prioritySortedAttractions.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "AttractionsTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? AttractionsTableViewCell else {
            fatalError("Dequeued cell wasn't AttractionsTableViewCell")
        }
        
        var index = indexPath.row
        
        if indexPath.section == 1 {
            index += userTypeQueryCount
        }
        
        let attraction = attrToProperName[prioritySortedAttractions[index]]
        
        // Check if this row had been selected, add a checkmark if it was selected before
        if (selectedAttractions.contains(prioritySortedAttractions[index])) {
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
        
        if selectedAttractions.count == 10 {
            // should pop an error here (First need to fix AnywhereAlertController)
            return
        }
        
        var index = indexPath.row
        
        if indexPath.section == 1 {
            index += userTypeQueryCount
        }
        
        // Set checkmark for row and add this attraction to the array of selected attractions
        cell.accessoryType = .checkmark
        selectedAttractions.append(prioritySortedAttractions[index])
        updateAttractionTableObservers()
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
        
        updateAttractionTableObservers()
    }
    
    func setAttractionTypes(attrToProperName: [String : String], properNameToAttr: [String : String], prioritySortedAttractions: [String], selectedAttractions: [String], userTypeQueryCount: Int) {
        self.attrToProperName = attrToProperName
        self.properNameToAttr = properNameToAttr
        self.prioritySortedAttractions = prioritySortedAttractions
        self.selectedAttractions = selectedAttractions
        self.userTypeQueryCount = userTypeQueryCount
    }
    
    func addAttractionTableObserver(observer: AttractionTableObserver) {
        self.observers.append(observer)
    }
    
    func updateAttractionTableObservers() {
        for observer in observers {
            observer.didUpdateSelectedRows(selected: selectedAttractions)
        }
    }
}
