//
//  LookupViewController.swift
//  BlipsClient
//
//  Created by Cyrus Sadeghi on 2017-11-21.
//  Copyright © 2017 Cyrus Sadeghi. All rights reserved.
//

import UIKit
import os.log

class LookupViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var cityIDSlider: UISlider!
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var cityIDLabel: UILabel!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    var lookupModel: LookupModel? = nil
    var pickerData: [String] = [String]()
    var customLookup: CustomLookup?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.picker.delegate = self
        self.picker.dataSource = self
        
        cityIDSlider.minimumValue = 0
        cityIDSlider.maximumValue = Float(lookupModel?.numCities ?? 1)
        
        // default array needs to be changed
        pickerData = lookupModel?.attractionTypes ?? ["Fail", "Fail"]
    }

    @IBAction func sliderChanged(_ sender: UISlider) {
        cityIDLabel.text = String(Int(sender.value))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    //MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let button = sender as? UIBarButtonItem, button === doneButton else {
            os_log("Cancel button pressed", log: OSLog.default, type: .debug)
            return
        }
        
        let cityID = cityIDSlider.value
        let attractionType = pickerData[picker.selectedRow(inComponent: 0)]
        
        customLookup = CustomLookup(cityID: Int(cityID), attributeType: attractionType)
        
        super.prepare(for: segue, sender: sender)
    }
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
