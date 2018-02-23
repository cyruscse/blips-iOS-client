//
//  QueryOptionsTableViewController.swift
//  BlipsClient
//
//  Created by Cyrus Sadeghi on 2018-02-23.
//  Copyright © 2018 Cyrus Sadeghi. All rights reserved.
//

import UIKit
import Cosmos

class QueryOptionsTableViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var attractionTypesToSelect: UITextField!
    @IBOutlet weak var starView: CosmosView!
    
    var attractionHistoryCount = 0
    var attractionHistoryCountArray: [String]!
    var autoQueryEnabled = true
    var openNow = true
    var priceRange = 0
    
    var observers = [QueryOptionsObserver]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let attractionTypesPicker = UIPickerView()
        attractionTypesToSelect.inputView = attractionTypesPicker
        attractionTypesToSelect.tintColor = UIColor.clear
        
        let pickerToolbar = UIToolbar()
        pickerToolbar.barStyle = .default
        pickerToolbar.isTranslucent = true
        pickerToolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(QueryOptionsTableViewController.donePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(QueryOptionsTableViewController.donePicker))
        
        pickerToolbar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        pickerToolbar.isUserInteractionEnabled = true
        attractionTypesToSelect.inputAccessoryView = pickerToolbar
        
        self.title = "Autoquery Options"
        starView.settings.fillMode = .precise
        starView.settings.minTouchRating = 0.0
        
        let intArray = Array(1...attractionHistoryCount)
        attractionHistoryCountArray = intArray.map { String($0) }

        attractionTypesPicker.showsSelectionIndicator = true
        attractionTypesPicker.delegate = self
    }

    @IBAction func autoQueryEnabledChanged(_ sender: UISwitch) {
        autoQueryEnabled = sender.isOn
        notifyAutoQueryStatusChanged(newValue: autoQueryEnabled)
    }
    
    @IBAction func openNowChanged(_ sender: UISwitch) {
        openNow = sender.isOn
        notifyOpenNowChanged(newValue: openNow)
    }
    
    @IBAction func priceRangeChanged(_ sender: UISegmentedControl) {
        priceRange = sender.selectedSegmentIndex
        notifyPriceRangeChanged(newValue: priceRange)
    }
    
    // MARK: - Observer Updating
    
    func addQueryOptionsObserver(observer: QueryOptionsObserver) {
        observers.append(observer)
    }
    
    func notifyAttractionTypesChanged(newValue: Int) {
        for observer in observers {
            observer.attractionTypesChanged(value: newValue)
        }
    }
    
    func notifyAutoQueryStatusChanged(newValue: Bool) {
        for observer in observers {
            observer.autoQueryStatusChanged(enabled: newValue)
        }
    }
    
    func notifyOpenNowChanged(newValue: Bool) {
        for observer in observers {
            observer.openNowChanged(value: newValue)
        }
    }
    
    func notifyRatingChanged(newValue: Double) {
        for observer in observers {
            observer.ratingChanged(rating: newValue)
        }
    }
    
    func notifyPriceRangeChanged(newValue: Int) {
        for observer in observers {
            observer.priceChanged(price: newValue)
            
            // Bundle in the rating here
            observer.ratingChanged(rating: starView.rating)
        }
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

    // MARK: - Picker View
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return attractionHistoryCountArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return attractionHistoryCountArray[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        attractionTypesToSelect.text = attractionHistoryCountArray[row]
        notifyAttractionTypesChanged(newValue: Int(attractionHistoryCountArray[row])!)
    }
    
    @objc
    func donePicker() {
        attractionTypesToSelect.resignFirstResponder()
    }
}
