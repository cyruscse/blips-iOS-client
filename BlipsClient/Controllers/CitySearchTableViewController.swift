//
//  CitySearchTableViewController.swift
//  BlipsClient
//
//  Created by Cyrus Sadeghi on 2018-03-03.
//  Copyright © 2018 Cyrus Sadeghi. All rights reserved.
//

import UIKit
import GooglePlaces

class CitySearchTableViewController: UITableViewController, UISearchResultsUpdating, UISearchControllerDelegate {
    let searchController = UISearchController(searchResultsController: nil)
    let filter = GMSAutocompleteFilter()
    
    var placesClient: GMSPlacesClient!
    var autoCompletedPlaces = [GMSAutocompletePrediction]()
    var autoCompletedPlacesStrings = [String]()
    var selectedCity: String!
    var cityPlaceID: String!
    var haveUserLocation: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 50.0
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Find City"
        searchController.delegate = self
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        filter.type = .city
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        searchController.isActive = true
    }
    
    func didPresentSearchController(_ searchController: UISearchController) {
        let delay = DispatchTime.now() + 0.1
        
        DispatchQueue.main.asyncAfter(deadline: delay) {
            searchController.searchBar.becomeFirstResponder()
        }
    }
    
    func addCurrentLocationEntry() {
        if self.viewIfLoaded?.window != nil {
            haveUserLocation = true
            autoCompletedPlacesStrings.insert("Current Location", at: 0)
            tableView.reloadData()
        }
    }

    // MARK: - UISearchResultsUpdating methods
    func updateSearchResults(for searchController: UISearchController) {
        if searchController.searchBar.text!.count == 0 {
            autoCompletedPlaces = [GMSAutocompletePrediction]()
            autoCompletedPlacesStrings = [String]()
            
            if haveUserLocation == true {
                autoCompletedPlacesStrings.append("Current Location")
            }
            
            tableView.reloadData()
            
            return
        }
        
        placesClient.autocompleteQuery(searchController.searchBar.text!, bounds: nil, filter: filter) { (results, error) in
            if let error = error {
                print("Autocompletion failed \(error)")
                return
            }
            
            if let results = results {
                self.autoCompletedPlaces = results
                self.autoCompletedPlacesStrings = [String]()
                self.autoCompletedPlacesStrings.append("Current Location")
                
                let autoCompStrings = results.map { $0.attributedFullText.string }
                self.autoCompletedPlacesStrings.append(contentsOf: autoCompStrings)
                
                self.tableView.reloadData()
            }
        }
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        if autoCompletedPlaces.count != 0 {
            tableView.separatorStyle = .singleLine
            tableView.backgroundView = nil
        } else {
            let noCitiesToDisplayLabel = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: tableView.bounds.width, height: tableView.bounds.height))
            let font = UIFontDescriptor(name: "Embrina", size: 30.0)
            
            noCitiesToDisplayLabel.text = "Search for a City"
            noCitiesToDisplayLabel.textColor = UIColor.lightGray
            noCitiesToDisplayLabel.baselineAdjustment = .alignBaselines
            noCitiesToDisplayLabel.backgroundColor = UIColor.clear
            noCitiesToDisplayLabel.textAlignment = .center
            noCitiesToDisplayLabel.font = UIFont(descriptor: font, size: 30.0)
            
            tableView.backgroundView = noCitiesToDisplayLabel
            tableView.separatorStyle = .none
        }
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return autoCompletedPlacesStrings.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "CitySearchCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? CitySearchTableViewCell else {
            fatalError("Dequeued cell wasn't \(cellIdentifier)")
        }

        cell.cityLabel.text = autoCompletedPlacesStrings[indexPath.row]

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? CitySearchTableViewCell else {
            fatalError("Cell wasn't CitySearchTableViewCell")
        }
        
        var autoCompletedPlacesIndex = indexPath.row
        
        if autoCompletedPlacesStrings.count > autoCompletedPlaces.count {
            autoCompletedPlacesIndex -= 1
        }
        
        selectedCity = cell.cityLabel.text
        
        if autoCompletedPlacesIndex != -1 {
            cityPlaceID = autoCompletedPlaces[autoCompletedPlacesIndex].placeID
        }
        
        searchController.searchBar.endEditing(true)
        
        self.navigationController?.popViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        searchController.isActive = false
    }
}
