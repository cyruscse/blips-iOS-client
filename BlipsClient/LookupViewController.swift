//
//  LookupViewController.swift
//  BlipsClient
//
//  Created by Cyrus Sadeghi on 2017-11-21.
//  Copyright © 2017 Cyrus Sadeghi. All rights reserved.
//

import UIKit
import os.log

class LookupViewController: UIViewController {
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var attractionsTableView: UITableView!
    
    var lookupModel: LookupModel? = nil
    var customLookup: CustomLookup?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationNC = segue.destination as? AttractionsTableViewController {
            destinationNC.setAttractions(incAttractions: self.lookupModel?.getAttractionTypes() ?? ["fail"])
        }
        
        super.prepare(for: segue, sender: sender)
    }
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
