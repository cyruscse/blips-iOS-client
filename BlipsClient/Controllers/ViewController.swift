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

    //abstract this and same function in LookupModel
   /* func serverPostCallback(data: Data) {
        do {
            let responseContents = try ServerInterface.readJSON(data: data)
            
            // this call needs to be fixed (call into MapModel??)
            //populateMap(serverDict: responseContents as? Dictionary<String, Dictionary<String, Any>> ?? [:])
        } catch ServerInterfaceError.JSONParseFailed(description: let error) {
            print(error)
        } catch {
            print("Other error")
        }
    }*/
    
    func relayUserLogin(account: User) {
        mainModel.relayUserLogin(account: account)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainModel.registerMapVC(mapVC: mapVC)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    //MARK: Navigation
    @IBAction func unwindToBlipMap(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? LookupViewController {
            mainModel.relayBlipLookup(lookupVC: sourceViewController)
        }
        /*
        if let sourceViewController = sender.source as? AccountViewController {
            let signedInStatus = sourceViewController.getSignInStatus()
            
            // If the user signs out, remove all blips from the map
            if signedInStatus == false {
                let allAnnotations = mapView.annotations
                mapView.removeAnnotations(allAnnotations)
            }
        }*/
    }
    
    // Triggered on "Cancel" bar button in SignInVC
    // Restore the annotations removed in segue preparation
    @IBAction func cancelToBlipMap(sender: UIStoryboardSegue) {
        /*mapView.addAnnotations(lastAnnotations)
        lastAnnotations.removeAll()*/
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationNC = segue.destination as? UINavigationController {
            if let lookupVC = destinationNC.topViewController as? LookupViewController {
                /*// Clear current annotations (pins) on map
                // We save these annotations in case the user cancels the blip request
                // On cancellation, cancelToBlipMap is invoked and the annotations are restored
                lastAnnotations = mapView.annotations
                mapView.removeAnnotations(lastAnnotations)*/
                
                mainModel.registerLookupVC(lookupVC: lookupVC)
            }
            if let accountVC = destinationNC.topViewController as? AccountViewController {
                mainModel.registerAccountVC(accountVC: accountVC)
            }
        }
    }
}
