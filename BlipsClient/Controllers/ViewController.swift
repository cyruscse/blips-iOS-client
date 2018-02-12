//
//  ViewController.swift
//  BlipsClient
//
//  Created by Cyrus Sadeghi on 2017-10-26.
//  Copyright © 2017 Cyrus Sadeghi. All rights reserved.
//

import Foundation
import UIKit

class ViewController: UIViewController, UIPopoverPresentationControllerDelegate {
    @IBOutlet weak var mapVC: MapViewController!
    @IBOutlet weak var blipTableVC: UIView!
    
    private let mainModel = MainModel()

    func relayUserLogin(account: User) {
        mainModel.relayUserLogin(account: account)
    }
    
    func relayAppDelegateLookupModelObserverAddition(observer: LookupModelObserver) {
        mainModel.relayLookupModelObserverAddition(observer: observer)
    }
    
    func relayBlipRowSelection(blip: Blip) {
        mainModel.relayBlipRowSelection(blip: blip)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapVC.setMainVC(vc: self)
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
    
    @IBAction func handlePan(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: self.blipTableVC)
        
        if let view = recognizer.view {
            view.center = CGPoint(x: view.center.x, y: view.center.y + translation.y)
            blipTableVC.center = CGPoint(x: blipTableVC.center.x, y: blipTableVC.center.y + translation.y)
        }
        
        recognizer.setTranslation(CGPoint.zero, in: self.blipTableVC)
    }

    func segueToBlipDetail(sender: UIControl, annotation: BlipMarkerView) {
        let blipDetailPop = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "blipDetailView") as? BlipDetailViewController
        
        blipDetailPop?.modalPresentationStyle = UIModalPresentationStyle.popover
        blipDetailPop?.popoverPresentationController?.delegate = self
        blipDetailPop?.popoverPresentationController?.sourceView = sender
        blipDetailPop?.popoverPresentationController?.sourceRect = sender.bounds
        
        blipDetailPop?.setBlipAnnotation(annotation: annotation)
        
        self.present(blipDetailPop!, animated: true, completion: nil)
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
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
        
        if let destinationVC = segue.destination as? BlipTableViewController {
            mainModel.registerBlipTableVC(blipTableVC: destinationVC)
            destinationVC.mainVC = self
        }
    }
}
