//
//  LookupViewController.swift
//  BlipsClient
//
//  Created by Cyrus Sadeghi on 2017-11-21.
//  Copyright © 2017 Cyrus Sadeghi. All rights reserved.
//

import UIKit
import os.log

class LookupViewController: UIViewController, LocationObserver, LookupModelObserver {
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    private var haveLocation: Bool = false
    private var attrToProperName = [String: String]()
    private var properNameToAttr = [String: String]()
    private var attractionsVC: AttractionsTableViewController?
    private var attributesVC: AttributesTableViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if haveLocation {
            self.doneButton.isEnabled = true
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func getSelectedAttractions() -> [String] {
        return attractionsVC?.getSelectedAttractions() ?? ["fail"]
    }
    
    func getOpenNowValue() -> Bool {
        return (attributesVC?.getOpenNowValue())!
    }
    
    func getRadiusValue() -> Int {
        return (attributesVC?.getRadiusValue())!
    }

    func locationDetermined() {
        haveLocation = true

        if self.viewIfLoaded?.window != nil {
            self.doneButton.isEnabled = true
        }
    }
    
    func setAttractionTypes(attrToProperName: [String : String], properNameToAttr: [String : String]) {
        self.attrToProperName = attrToProperName
        self.properNameToAttr = properNameToAttr
    }
    
    //MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? AttractionsTableViewController {
            attractionsVC = destinationVC
            attractionsVC?.setAttractionTypes(attrToProperName: attrToProperName, properNameToAttr: properNameToAttr)
        }
        else if let destinationVC = segue.destination as? AttributesTableViewController {
            attributesVC = destinationVC
        }
        
        super.prepare(for: segue, sender: sender)
    }
}
