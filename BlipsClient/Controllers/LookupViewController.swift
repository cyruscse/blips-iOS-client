//
//  LookupViewController.swift
//  BlipsClient
//
//  Created by Cyrus Sadeghi on 2017-11-21.
//  Copyright © 2017 Cyrus Sadeghi. All rights reserved.
//

import UIKit
import CoreLocation

class LookupViewController: UIViewController, LocationObserver, LookupModelObserver, AttractionTableObserver {
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    private static var haveLocation: Bool = false
    private static var selectedAttractions: Int = 0
    private var attrToProperName = [String: String]()
    private var properNameToAttr = [String: String]()
    private var prioritySortedAttractions = [String]()
    private var attractionsVC: AttractionsTableViewController?
    private var attributesVC: AttributesTableViewController?
    private var userLocation: CLLocationCoordinate2D!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (LookupViewController.selectedAttractions > 0) && (LookupViewController.selectedAttractions < 11) && (LookupViewController.haveLocation) {
            self.doneButton.isEnabled = true
        }
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
    
    func getPriceRange() -> Int {
        return (attributesVC?.getPriceRange())!
    }
    
    func getMinimumRating() -> Double {
        return (attributesVC?.getMinimumRating())!
    }
    
    func getLatitude() -> Double {
        return (attributesVC?.cityCoordinates.latitude)!
    }
    
    func getLongitude() -> Double {
        return (attributesVC?.cityCoordinates.longitude)!
    }
    
    func didUpdateSelectedRows(selected: Int) {
        LookupViewController.selectedAttractions = selected
        
        if (LookupViewController.selectedAttractions > 0) && (LookupViewController.selectedAttractions < 11) && (LookupViewController.haveLocation) {
            self.doneButton.isEnabled = true
        }
        else {
            self.doneButton.isEnabled = false
        }
    }
    
    // LocationObserver Methods
    func locationDetermined(location: CLLocationCoordinate2D) {
        LookupViewController.haveLocation = true
        
        attributesVC?.cityCoordinates = location
        self.userLocation = location
        
        if (self.viewIfLoaded?.window != nil) && (LookupViewController.selectedAttractions > 0) && (LookupViewController.selectedAttractions < 11) {
            self.doneButton.isEnabled = true
        }
    }
    
    // LookupModelObserver Methods
    func setAttractionTypes(attrToProperName: [String : String], properNameToAttr: [String : String], prioritySortedAttractions: [String]) {
        self.attrToProperName = attrToProperName
        self.properNameToAttr = properNameToAttr
        self.prioritySortedAttractions = prioritySortedAttractions
    }
    
    func gotGoogleClientKey(key: String) {}
    
    //MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? AttractionsTableViewController {
            attractionsVC = destinationVC
            attractionsVC?.addAttractionTableObserver(observer: self)
            attractionsVC?.setAttractionTypes(attrToProperName: attrToProperName, properNameToAttr: properNameToAttr, prioritySortedAttractions: prioritySortedAttractions)
        } else if let destinationVC = segue.destination as? AttributesTableViewController {
            attributesVC = destinationVC
            attributesVC?.cityCoordinates = userLocation
        }
        
        super.prepare(for: segue, sender: sender)
    }
}
