///
//  AttributesTableViewController.swift
//  BlipsClient
//
//  Created by Cyrus Sadeghi on 2018-01-13.
//  Copyright © 2018 Cyrus Sadeghi. All rights reserved.
//

import UIKit
import Cosmos

class AttributesTableViewController: UITableViewController {
    @IBOutlet weak var radiusTextField: UITextField!
    @IBOutlet weak var openNowCell: UITableViewCell!
    @IBOutlet weak var radiusCell: UITableViewCell!
    @IBOutlet weak var priceCell: UITableViewCell!
    @IBOutlet weak var ratingCell: UITableViewCell!
    @IBOutlet weak var starView: CosmosView!
    
    private let defaultRadius = 5000
    private var openNow: Bool = true
    private var radius: Int = 0
    private var priceRange: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        openNowCell.selectionStyle = .none
        radiusCell.selectionStyle = .none
        priceCell.selectionStyle = .none
        ratingCell.selectionStyle = .none
        
        starView.settings.fillMode = .precise
        starView.settings.minTouchRating = 0.0
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
        return 4
    }
}
