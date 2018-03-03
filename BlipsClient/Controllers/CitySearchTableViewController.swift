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
    var selectedCity: String!
    var cityPlaceID: String!
    
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

    // MARK: - UISearchResultsUpdating methods
    func updateSearchResults(for searchController: UISearchController) {
        if searchController.searchBar.text!.count == 0 {
            autoCompletedPlaces = [GMSAutocompletePrediction]()
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
        return autoCompletedPlaces.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "CitySearchCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? CitySearchTableViewCell else {
            fatalError("Dequeued cell wasn't \(cellIdentifier)")
        }

        cell.cityLabel.text = autoCompletedPlaces[indexPath.row].attributedFullText.string

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? CitySearchTableViewCell else {
            fatalError("Cell wasn't CitySearchTableViewCell")
        }
        
        selectedCity = cell.cityLabel.text
        cityPlaceID = autoCompletedPlaces[indexPath.row].placeID
        searchController.searchBar.endEditing(true)
        
        self.navigationController?.popViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        searchController.isActive = false
    }
}
