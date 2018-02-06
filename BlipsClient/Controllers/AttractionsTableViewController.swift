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
    
    func setAttractionTypes(attrToProperName: [String : String], properNameToAttr: [String : String], prioritySortedAttractions: [String]) {
        self.attrToProperName = attrToProperName
        self.properNameToAttr = properNameToAttr
        self.prioritySortedAttractions = prioritySortedAttractions
    }
    
    func addAttractionTableObserver(observer: AttractionTableObserver) {
        self.observers.append(observer)
    }
    
    func updateAttractionTableObservers(numRows: Int) {
        for observer in observers {
            observer.didUpdateSelectedRows(selected: numRows)
        }
    }

    func getSelectedAttractions() -> [String] {
        return self.selectedAttractions
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.allowsMultipleSelection = true
        self.tableView.rowHeight = 44.0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return prioritySortedAttractions.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "AttractionsTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? AttractionsTableViewCell else {
            fatalError("Dequeued cell wasn't AttractionsTableViewCell")
        }
        
        let attraction = attrToProperName[prioritySortedAttractions[indexPath.row]]
        
        // Check if this row had been selected, add a checkmark if it was selected before
        if (selectedAttractions.contains(prioritySortedAttractions[indexPath.row])) {
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
        selectedAttractions.append(prioritySortedAttractions[indexPath.row])
        updateAttractionTableObservers(numRows: selectedAttractions.count)
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
        updateAttractionTableObservers(numRows: selectedAttractions.count)
    }
}
