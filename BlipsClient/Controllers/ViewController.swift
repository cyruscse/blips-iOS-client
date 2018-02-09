//
//  ViewController.swift
//  BlipsClient
//
//  Created by Cyrus Sadeghi on 2017-10-26.
//  Copyright © 2017 Cyrus Sadeghi. All rights reserved.
//

import Foundation
import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var mapVC: MapViewController!
    private let mainModel = MainModel()

    func relayUserLogin(account: User) {
        mainModel.relayUserLogin(account: account)
    }
    
    func relayAppDelegateLookupModelObserverAddition(observer: LookupModelObserver) {
        mainModel.relayLookupModelObserverAddition(observer: observer)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainModel.registerMapVC(mapVC: mapVC)
    }

    //MARK: Navigation
    @IBAction func unwindToBlipMap(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? LookupViewController {
            mainModel.relayBlipLookup(lookupVC: sourceViewController)
        }
        if let _ = sender.source as? AccountViewController {
            mainModel.clearMapVC(retainAnnotations: false)
        }
    }
    
    // Triggered on "Cancel" bar button in SignInVC
    // Restore the annotations removed in segue preparation
    @IBAction func cancelToBlipMap(sender: UIStoryboardSegue) {
        mainModel.restoreMapVC()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationNC = segue.destination as? UINavigationController {
            if let lookupVC = destinationNC.topViewController as? LookupViewController {
                mainModel.clearMapVC(retainAnnotations: true)
                mainModel.registerLookupVC(lookupVC: lookupVC)
            }
            if let accountVC = destinationNC.topViewController as? AccountViewController {
                mainModel.registerAccountVC(accountVC: accountVC)
            }
        }
    }
}
