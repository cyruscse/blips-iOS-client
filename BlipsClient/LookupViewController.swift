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
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    var lookupModel: LookupModel? = nil
    var pickerData: [String] = [String]()
    var customLookup: CustomLookup?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.picker.delegate = self
        self.picker.dataSource = self
        
        // default array needs to be changed
        pickerData = lookupModel?.attractionTypes ?? ["Fail", "Fail"]
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
        
        let attractionType = pickerData[picker.selectedRow(inComponent: 0)]
        
        customLookup = CustomLookup(attributeType: attractionType)
        
        super.prepare(for: segue, sender: sender)
    }
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
