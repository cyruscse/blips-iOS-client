 ///
//  AttributesTableViewController.swift
//  BlipsClient
//
//  Created by Cyrus Sadeghi on 2018-01-13.
//  Copyright © 2018 Cyrus Sadeghi. All rights reserved.
//

import UIKit
import Cosmos
import GooglePlaces

class AttributesTableViewController: UITableViewController {
    @IBOutlet weak var radiusTextField: UITextField!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var starView: CosmosView!
    
    private let defaultRadius = 5000
    private var openNow: Bool = true
    private var radius: Int = 0
    private var priceRange: Int = 0
    private var citySearchVC: CitySearchTableViewController?

    var placesClient: GMSPlacesClient!
    var bounds: GMSCoordinateBounds!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        starView.settings.fillMode = .precise
        starView.settings.minTouchRating = 0.0
        
        placesClient = GMSPlacesClient.shared()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        cityLabel.text = citySearchVC?.selectedCity
    }

    @IBAction func openNowChanged(_ sender: UISwitch) {
        openNow = sender.isOn
    }
    
    @IBAction func priceRangeChanged(_ sender: UISegmentedControl) {
        priceRange = sender.selectedSegmentIndex
    }

    func getOpenNowValue() -> Bool {
        return openNow
    }
    
    func getRadiusValue() -> Int {
        if radiusTextField.text?.count == 0 {
            return defaultRadius
        }
        
        let radiusValue = radiusTextField?.text ?? "0"
        
        self.view.endEditing(true)
        
        return Int(radiusValue)!
    }
    
    func getPriceRange() -> Int {
        return priceRange
    }
    
    func getMinimumRating() -> Double {
        return starView.rating
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    // Needs to be equal to the number of rows in the table view, else the row isn't shown
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? CitySearchTableViewController {
            citySearchVC = destinationVC
            destinationVC.placesClient = placesClient
        }
        
        super.prepare(for: segue, sender: sender)
    }
}
