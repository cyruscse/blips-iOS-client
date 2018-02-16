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
    @IBOutlet weak var blipTableVC: MapAccessoryView!
    @IBOutlet weak var grabberView: MapAccessoryView!
    @IBOutlet weak var toggleTable: BlipTableToggleButton!
    @IBOutlet weak var toggleTableYPlacement: NSLayoutConstraint!
    
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
        mainModel.registerMapModelObserver(observer: grabberView)
        mainModel.registerMapModelObserver(observer: blipTableVC)
        mainModel.registerMapModelObserver(observer: toggleTable)
        
       // toggleTableYPlacement.isActive = false
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
            let oldViewFrame = view.frame
            let oldTableFrame = blipTableVC.frame
            let oldButtonFrame = toggleTable.frame
            
            view.center = CGPoint(x: view.center.x, y: view.center.y + translation.y)
            toggleTable.center = CGPoint(x: toggleTable.center.x, y: toggleTable.center.y + translation.y)
            blipTableVC.center = CGPoint(x: blipTableVC.center.x, y: blipTableVC.center.y + translation.y)
            blipTableVC.frame.size.height -= translation.y
            
            if (((toggleTable.frame.minY - 8) < mapVC.frame.minY) || (view.frame.maxY > mapVC.frame.maxY)) {
                view.frame = oldViewFrame
                blipTableVC.frame = oldTableFrame
                toggleTable.frame = oldButtonFrame
            }
            
            if view.frame.maxY >= (mapVC.frame.maxY * 0.95) {
                blipTableVC.asyncHide(animationType: AccessoryAnimationType.fade, scrollPosition: 0.0)
                grabberView.asyncHide(animationType: AccessoryAnimationType.fade, scrollPosition: 0.0)
                toggleTable.scrollView(scrollPosition: mapVC.frame.maxY - toggleTable.frame.size.height)
                
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
        if sender.viewsVisible {
            blipTableVC.asyncHide(animationType: AccessoryAnimationType.scroll, scrollPosition: mapVC.frame.maxY * 2)
            grabberView.asyncHide(animationType: AccessoryAnimationType.scroll, scrollPosition: mapVC.frame.maxY * 2)
            toggleTable.scrollView(scrollPosition: mapVC.frame.maxY - toggleTable.frame.size.height)
        } else {
            blipTableVC.asyncShow(animationType: AccessoryAnimationType.scroll)
            grabberView.asyncShow(animationType: AccessoryAnimationType.scroll)
            toggleTable.scrollView(scrollPosition: 0.0)
        }
        
        sender.rotateButtonImage()
        sender.viewsVisible = !sender.viewsVisible
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
            mainModel.registerMapModelObserver(observer: destinationVC)
            destinationVC.mainVC = self
        }
    }
}
