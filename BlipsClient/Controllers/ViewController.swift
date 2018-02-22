//
//  ViewController.swift
//  BlipsClient
//
//  Created by Cyrus Sadeghi on 2017-10-26.
//  Copyright © 2017 Cyrus Sadeghi. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class ViewController: UIViewController, UIPopoverPresentationControllerDelegate, MapModelObserver {
    @IBOutlet weak var mapVC: MapViewController!
    @IBOutlet weak var blipTableVC: MapAccessoryView!
    @IBOutlet weak var grabberView: MapAccessoryView!
    @IBOutlet weak var toggleTable: BlipTableToggleButton!
    @IBOutlet weak var refreshMap: MapRefreshButton!
    
    @IBOutlet weak var toggleTableYPlacement: NSLayoutConstraint!
    @IBOutlet weak var blipTableVCYPlacement: NSLayoutConstraint!
    
    private let mainModel = MainModel()
    private var blipTableVCasVC: BlipTableViewController?

    private let animationTimer: Double = 0.25
    private var maximumTableSize: CGFloat!
    private var safeAreaHeight: CGFloat!
    private var bottomPadding: CGFloat!

    func relayUserLogin(account: User) {
        mainModel.relayUserLogin(account: account)
    }
    
    func relayAppDelegateLookupModelObserverAddition(observer: LookupModelObserver) {
        mainModel.relayLookupModelObserverAddition(observer: observer)
    }
    
    func relayBlipRowSelection(blip: Blip) {
        mainModel.relayBlipRowSelection(blip: blip)
        resizeTableView(percentage: -0.33)
    }
    
    func annotationsUpdated(annotations: [MKAnnotation]) {
        let tableView = blipTableVCasVC?.view as! UITableView
        self.blipTableVCYPlacement.constant = 0.0
        self.maximumTableSize = 0.0
        
        if toggleTable.viewsVisible == false {
            toggleTable.viewsVisible = true
            toggleTable.rotateButtonImage()
        }
        
        DispatchQueue.main.async {
            if annotations.count == 0 {
                return
            }

            let tableHeight = CGFloat(annotations.count) * tableView.rowHeight
            self.maximumTableSize = self.safeAreaHeight / 2 - tableHeight
            
            if self.maximumTableSize > CGFloat(0.0) {
                self.blipTableVCYPlacement.constant -= self.maximumTableSize
            } else {
                self.blipTableVCYPlacement.constant -= self.bottomPadding
            }
        }
    }
    
    func locationUpdated(location: CLLocationCoordinate2D, latitudinalMeters: CLLocationDistance, longitudinalMeters: CLLocationDistance) {}
    
    func focusOnBlip(blip: Blip) {}

    override func viewDidLoad() {
        super.viewDidLoad()
        let window = UIApplication.shared.keyWindow
        bottomPadding = window?.safeAreaInsets.bottom
        safeAreaHeight = (mapVC.frame.height - bottomPadding!)
        
        blipTableVC.animationTimer = self.animationTimer
        grabberView.animationTimer = self.animationTimer
        toggleTable.animationTimer = self.animationTimer
        refreshMap.animationTimer = self.animationTimer
        
        mapVC.setMainVC(vc: self)
        mainModel.registerMapVC(mapVC: mapVC)
        mainModel.registerMapModelObserver(observer: grabberView)
        mainModel.registerMapModelObserver(observer: blipTableVC)
        mainModel.registerMapModelObserver(observer: toggleTable)
        mainModel.registerMapModelObserver(observer: self)
    }
    
    //MARK: Map Accessory Animations
    @IBAction func handlePan(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: self.blipTableVC)

        if let view = recognizer.view {
            if (((toggleTable.frame.minY + translation.y) < mapVC.frame.minY) || (view.frame.maxY > mapVC.frame.maxY) ||
                ((maximumTableSize + mapVC.frame.midY) >= (blipTableVC.frame.minY - (bottomPadding * 3) + translation.y))) {
                return
            }
            
            blipTableVCYPlacement.constant -= translation.y
            
            if view.frame.maxY >= (mapVC.frame.maxY * 0.95) {
                blipTableVC.asyncHide()
                grabberView.asyncHide()
                blipTableVCYPlacement.constant = -(mapVC.frame.height / 2 + toggleTable.frame.height / 2)
                
                if toggleTable.viewsVisible == true {
                    toggleTable.rotateButtonImage()
                }
                
                toggleTable.viewsVisible = false
                recognizer.isEnabled = false
            }
            
            if (recognizer.isEnabled == false) {
                recognizer.isEnabled = true
            }
        }
        
        recognizer.setTranslation(CGPoint.zero, in: self.blipTableVC)
    }
    
    @IBAction func toggleTableView(_ sender: BlipTableToggleButton) {
        self.view.layoutIfNeeded()
        
        if sender.viewsVisible {
            blipTableVCYPlacement.constant -= (blipTableVC.frame.height + toggleTable.frame.height / 2)
            blipTableVC.makeInVisible()
            grabberView.makeInVisible()
        } else {
            if abs(maximumTableSize) > (mapVC.frame.height / 2) {
                blipTableVCYPlacement.constant = 0.0
            } else {
                blipTableVCYPlacement.constant = (maximumTableSize + bottomPadding)
            }
            
            blipTableVC.makeVisible()
            grabberView.makeVisible()
        }
        
        UIView.animate(withDuration: animationTimer) {
            self.view.layoutIfNeeded()
        }
        
        sender.rotateButtonImage()
        sender.viewsVisible = !sender.viewsVisible
    }

    @IBAction func refreshMap(_ sender: MapRefreshButton) {
    }
    
    func resizeTableView(percentage: CGFloat) {
        if !toggleTable.viewsVisible {
            return
        }
        
        let location = percentage * (mapVC.frame.height / 2)
        
        self.view.layoutIfNeeded()
        blipTableVCYPlacement.constant = location
        
        UIView.animate(withDuration: animationTimer) {
            self.view.layoutIfNeeded()
        }
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
    
    func segueToBlipDetail(sender: UIControl, annotation: BlipMarkerView) {
        let blipDetailPop = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "blipDetailView") as? BlipDetailViewController
        
        blipDetailPop?.modalPresentationStyle = UIModalPresentationStyle.popover
        blipDetailPop?.popoverPresentationController?.delegate = self
        blipDetailPop?.popoverPresentationController?.sourceView = sender
        blipDetailPop?.popoverPresentationController?.sourceRect = sender.bounds
                
        if annotation.blip.information == "" {
            let noDescriptionSize = CGSize(width: self.view.frame.width, height: self.view.frame.height * (0.6))
            blipDetailPop?.preferredContentSize = noDescriptionSize
        }
        
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
            mainModel.registerMapModelObserver(observer: destinationVC)
            destinationVC.mainVC = self
            self.blipTableVCasVC = destinationVC
        }
    }
}
