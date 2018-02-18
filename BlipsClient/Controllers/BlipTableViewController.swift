//
//  BlipTableViewController.swift
//  BlipsClient
//
//  Created by Cyrus Sadeghi on 2018-02-11.
//  Copyright © 2018 Cyrus Sadeghi. All rights reserved.
//

import UIKit
import MapKit
import SDWebImage

class BlipTableViewController: UITableViewController, MapModelObserver {
    private var currentBlips = [Blip]()
    var mainVC: ViewController!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.rowHeight = 44.0
        
        if (currentBlips.count == 0) {
            self.hideTableView()
        } else {
            self.restoreTableView()
        }
    }
    
    func hideTableView() {
        self.view.isHidden = true
        self.view.isUserInteractionEnabled = false
    }
    
    func restoreTableView() {
        self.view.isHidden = false
        self.view.isUserInteractionEnabled = true
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentBlips.count
    }
    
    func annotationsUpdated(annotations: [MKAnnotation]) {
        if let asBlips = annotations as? [Blip] {
            self.currentBlips = asBlips
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()

            if self.currentBlips.count == 0 {
                self.hideTableView()
            } else {
                self.restoreTableView()
            }
        }
    }
    
    func locationUpdated(location: CLLocationCoordinate2D, latitudinalMeters: CLLocationDistance, longitudinalMeters: CLLocationDistance) {}
    func focusOnBlip(blip: Blip) {}

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "BlipTableViewCell"

        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? BlipTableViewCell else {
            fatalError("Dequeued cell wasn't BlipTableViewCell")
        }

        let blip = currentBlips[indexPath.row]
        
        cell.selectionStyle = .none
        cell.blipName.text = blip.title
        cell.blipType.text = blip.attractionType
        cell.typeImage.sd_setImage(with: blip.icon) { (_, _, _, _) in }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let _ = tableView.cellForRow(at: indexPath) as? BlipTableViewCell else {
            fatalError("Cell wasn't BlipTableViewCell")
        }
        
        mainVC.relayBlipRowSelection(blip: currentBlips[indexPath.row])
    }
}
