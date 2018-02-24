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
    @IBOutlet weak var attractionTypeToSelectLabel: UILabel!
    @IBOutlet weak var autoQueryEnabledSwitch: UISwitch!
    @IBOutlet weak var openNowSwitch: UISwitch!
    @IBOutlet weak var priceRangeControl: UISegmentedControl!
    @IBOutlet weak var starView: CosmosView!
    
    var attractionHistoryCount = 0
    var attractionHistoryCountArray: [String]!
    var queryOptions: AutoQueryOptions!
    
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
        starView.didFinishTouchingCosmos = { rating in self.notifyRatingChanged(newValue: rating) }
        
        if attractionHistoryCount == 0 {
            attractionTypesToSelect.isEnabled = false
            attractionTypeToSelectLabel.textColor = UIColor.lightGray
            attractionTypesToSelect.text = ""
        } else {
            let intArray = Array(1...attractionHistoryCount)
            attractionHistoryCountArray = intArray.map { String($0) }
            
            attractionTypesToSelect.text = String(queryOptions.autoQueryTypeGrabLength)
            attractionTypesPicker.selectRow(queryOptions.autoQueryTypeGrabLength - 1, inComponent: 0, animated: false)
        }

        attractionTypesPicker.showsSelectionIndicator = true
        attractionTypesPicker.delegate = self
        
        if queryOptions.autoQueryTypeGrabLength == 0 {
            queryOptions.autoQueryTypeGrabLength = attractionHistoryCount / 2
            notifyAttractionTypesChanged(newValue: queryOptions.autoQueryTypeGrabLength)
        }
        
        autoQueryEnabledSwitch.isOn = queryOptions.autoQueryEnabled
        openNowSwitch.isOn = queryOptions.autoQueryOpenNow
        priceRangeControl.selectedSegmentIndex = queryOptions.autoQueryPriceRange
        starView.rating = queryOptions.autoQueryRating
    }

    @IBAction func autoQueryEnabledChanged(_ sender: UISwitch) {
        queryOptions.autoQueryEnabled = sender.isOn
        notifyAutoQueryStatusChanged(newValue: queryOptions.autoQueryEnabled)
    }
    
    @IBAction func openNowChanged(_ sender: UISwitch) {
        queryOptions.autoQueryOpenNow = sender.isOn
        notifyOpenNowChanged(newValue: queryOptions.autoQueryOpenNow)
    }
    
    @IBAction func priceRangeChanged(_ sender: UISegmentedControl) {
        queryOptions.autoQueryPriceRange = sender.selectedSegmentIndex
        notifyPriceRangeChanged(newValue: queryOptions.autoQueryPriceRange)
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
