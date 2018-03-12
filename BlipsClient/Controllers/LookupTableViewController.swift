///
//  LookupTableViewController.swift
//  BlipsClient
//
//  Created by Cyrus Sadeghi on 2018-01-13.
//  Copyright © 2018 Cyrus Sadeghi. All rights reserved.
//

import UIKit
import Cosmos
import GooglePlaces

class LookupTableViewController: UITableViewController, LookupModelObserver, AttractionTableObserver {
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var radiusTextField: UITextField!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var starView: CosmosView!
    
    private let currentLocationStr = "Current Location"
    
    private let defaultRadius = 5000
    private var radius: Int = 0
    
    var openNow = true
    var priceRange: Int = 0
    
    var haveLookupLocation = false
    var haveUserLocation = false
    
    var selectedAttractionTypes = [String]()
    var attrToProperName = [String: String]()
    var properNameToAttr = [String: String]()
    var prioritySortedAttractions = [String]()
    var userTypeQueryCount: Int = 0
    
    var deviceLocation: CLLocationCoordinate2D?
    var cityCoordinates: CLLocationCoordinate2D!
    var placesClient: GMSPlacesClient!
    var bounds: GMSCoordinateBounds!
    var citySearchVC: CitySearchTableViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        starView.settings.fillMode = .precise
        starView.settings.minTouchRating = 0.0
        
        placesClient = GMSPlacesClient.shared()
        
        if (cityCoordinates != nil) && (citySearchVC?.selectedCity == nil) {
            cityLabel.text = currentLocationStr
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
        
        if citySearchVC?.selectedCity != cityLabel.text && citySearchVC?.selectedCity != nil {
            cityLabel.text = citySearchVC?.selectedCity
            
            if citySearchVC?.selectedCity == currentLocationStr {
                locationDetermined(location: deviceLocation!, haveDeviceLocation: true)
                return
            }
            
            placesClient.lookUpPlaceID(citySearchVC!.cityPlaceID, callback: { (place, error) in
                if let error = error {
                    print("Place lookup failed for city \(self.citySearchVC!.selectedCity) \(error)")
                    return
                }
                
                guard let place = place else {
                    print("No details for city \(self.citySearchVC!.selectedCity)")
                    return
                }
                
                self.cityCoordinates = place.coordinate
                self.locationDetermined(location: self.cityCoordinates, haveDeviceLocation: false)
            })
        }
    }
    
    // LocationObserver Methods
    func locationDetermined(location: CLLocationCoordinate2D, haveDeviceLocation: Bool) {
        haveLookupLocation = true
        
        if haveDeviceLocation == true {
            deviceLocation = location
            haveUserLocation = true
            setCityCoordinates(coordinates: location)
        }
        
        if (self.viewIfLoaded?.window != nil) && (selectedAttractionTypes.count > 0) && (selectedAttractionTypes.count < 11) {
            self.doneButton.isEnabled = true
        }
    }
    
    func setAttractionTypes(attrToProperName: [String : String], properNameToAttr: [String : String], prioritySortedAttractions: [String], userTypeQueryCount: Int) {
        self.attrToProperName = attrToProperName
        self.properNameToAttr = properNameToAttr
        self.prioritySortedAttractions = prioritySortedAttractions
        self.userTypeQueryCount = userTypeQueryCount
    }
    
    func didUpdateSelectedRows(selected: [String]) {
        selectedAttractionTypes = selected
        
        if (selectedAttractionTypes.count > 0) && (selectedAttractionTypes.count < 11) && (haveLookupLocation) {
            doneButton.isEnabled = true
        } else {
            doneButton.isEnabled = false
        }
    }
    
    func gotGoogleClientKey(key: String) {}

    @IBAction func openNowChanged(_ sender: UISwitch) {
        openNow = sender.isOn
    }
    
    @IBAction func priceRangeChanged(_ sender: UISegmentedControl) {
        priceRange = sender.selectedSegmentIndex
    }
    
    func getRadiusValue() -> Int {
        if radiusTextField.text?.count == 0 {
            return defaultRadius
        }
        
        let radiusValue = radiusTextField?.text ?? "0"
        
        self.view.endEditing(true)
        
        return Int(radiusValue)!
    }
    
    func getMinimumRating() -> Double {
        return starView.rating
    }
    
    func setCityCoordinates(coordinates: CLLocationCoordinate2D?) {
        cityCoordinates = coordinates
        citySearchVC?.addCurrentLocationEntry()
        
        if cityLabel != nil && cityLabel.text == "" {
            cityLabel.text = currentLocationStr
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Section 0 is the Lookup Attributes (5 rows, City, Open Now, Radius, Price, Rating)
        // Section 1 is the Lookup Types (2 rows, one to open AttractionsTVC, one to display selected types)
        if section == 0 {
            return 5
        }
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if selectedAttractionTypes.count == 0 {
            return nil
        }
        
        if section == 1 {
            var selectedLabelText = "Selected: "
            
            for selection in selectedAttractionTypes {
                selectedLabelText.append(attrToProperName[selection] ?? selection)
                
                if selection != selectedAttractionTypes.last {
                    selectedLabelText.append(", ")
                }
            }
            
            return selectedLabelText
        }
        
        return nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? CitySearchTableViewController {
            citySearchVC = destinationVC
            destinationVC.placesClient = placesClient
            destinationVC.haveUserLocation = haveUserLocation
        } else if let destinationVC = segue.destination as? AttractionsTableViewController {
            destinationVC.addAttractionTableObserver(observer: self)
            destinationVC.setAttractionTypes(attrToProperName: attrToProperName, properNameToAttr: properNameToAttr, prioritySortedAttractions: prioritySortedAttractions, selectedAttractions: selectedAttractionTypes, userTypeQueryCount: userTypeQueryCount)
        }
        
        super.prepare(for: segue, sender: sender)
    }
}
