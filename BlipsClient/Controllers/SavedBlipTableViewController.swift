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
    var selectedBlips: [Blip] = [Blip]()
    private var observers = [SavedBlipTableObserver]()
    private var doneButtonItem: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        doneButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.doneButtonPressed(sender:)))
        doneButtonItem.isEnabled = false
        
        self.tableView.allowsMultipleSelection = true
        self.tableView.rowHeight = 44.0
        self.navigationItem.title = "Saved Blips"
        self.navigationItem.rightBarButtonItem = doneButtonItem
    }
    
    @objc func doneButtonPressed(sender: UIBarButtonItem) {
        performSegue(withIdentifier: "querySelectedBlips", sender: self)
    }
    
    func addObserver(observer: SavedBlipTableObserver) {
        observers.append(observer)
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

        if selectedBlips.contains(blip) {
            cell.accessoryType = .checkmark
        }
        
        cell.selectionStyle = .none
        cell.blipName.text = blip.title
        cell.blipType.text = blip.attractionType
        cell.typeImage.sd_setImage(with: blip.icon) { (_, _, _, _) in }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let unsave = UITableViewRowAction(style: .destructive, title: "Unsave") { (action, indexPath) in
            let unsavedBlip = self.savedBlips[indexPath.row]
            self.savedBlips.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            for observer in self.observers {
                observer.blipUnsaved(blip: unsavedBlip)
            }
        }
        
        return [unsave]
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }
    
    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedBlip = self.savedBlips[sourceIndexPath.row]
        savedBlips.remove(at: sourceIndexPath.row)
        savedBlips.insert(movedBlip, at: destinationIndexPath.row)
        
        for observer in observers {
            observer.reorderedBlips(sourceRow: sourceIndexPath.row, destinationRow: destinationIndexPath.row)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? BlipTableViewCell else {
            fatalError("Cell wasn't BlipTableViewCell")
        }
        
        cell.accessoryType = .checkmark
        selectedBlips.append(savedBlips[indexPath.row])
        
        doneButtonItem.isEnabled = true
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? BlipTableViewCell else {
            fatalError("Cell wasn't BlipTableViewCell")
        }
        
        cell.accessoryType = .none
        let index = selectedBlips.index(of: savedBlips[indexPath.row])
        selectedBlips.remove(at: index!)
        
        if selectedBlips.count == 0 {
            doneButtonItem.isEnabled = false
        }
    }
}
