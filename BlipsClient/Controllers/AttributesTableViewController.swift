///
//  AttributesTableViewController.swift
//  BlipsClient
//
//  Created by Cyrus Sadeghi on 2018-01-13.
//  Copyright © 2018 Cyrus Sadeghi. All rights reserved.
//

import UIKit

class AttributesTableViewController: UITableViewController {
    @IBOutlet weak var radiusTextField: UITextField!
    @IBOutlet weak var openNowCell: UITableViewCell!
    @IBOutlet weak var radiusCell: UITableViewCell!
    
    private let defaultRadius = 5000
    private var openNow: Bool = true
    private var radius: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        openNowCell.selectionStyle = .none
        radiusCell.selectionStyle = .none
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func openNowChanged(_ sender: UISwitch) {
        openNow = sender.isOn
    }
    
    func getOpenNowValue() -> Bool {
        return openNow
    }
    
    func getRadiusValue() -> Int {
        if radiusTextField.text?.count == 0 {
            return defaultRadius
        }
        
        let radiusValue = radiusTextField?.text ?? "0"
        
        return Int(radiusValue)!
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
}
