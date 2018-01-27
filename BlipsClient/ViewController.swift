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

// SEPARATE CLASSES SOON

class ViewController: UIViewController, LocationObserver {
    @IBOutlet weak var mapView: MKMapView!
    
    private var userLatitude: Double = 0.0
    private var userLongitude: Double = 0.0
    
    let locManager = Location()
    let regionRadius: CLLocationDistance = 250
    let lookupModel = LookupModel()
    let signInModel = SignInModel()
    
    var blips = [Blip]()
    var gotUserLocation: Bool = false
    var lastAnnotations = [MKAnnotation]()
    
    func centerMapOnBlipCity(location: CLLocationCoordinate2D) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location, regionRadius, regionRadius)
        
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func placePinForBlip(blip: Blip) {
        let annotation = MKPointAnnotation()
        let coordinate = CLLocationCoordinate2D(latitude: blip.getLatitude(), longitude: blip.getLongitude())
        
        annotation.coordinate = coordinate
        annotation.title = blip.getName()
        mapView.addAnnotation(annotation)
    }

    //abstract this and same function in LookupModel
    func serverPostCallback(data: Data) {
        do {
            let responseContents = try ServerInterface.readJSON(data: data)
            
            populateMap(serverDict: responseContents as? Dictionary<String, Dictionary<String, Any>> ?? [:])
        } catch ServerInterfaceError.JSONParseFailed(description: let error) {
            print(error)
        } catch {
            print("Other error")
        }
    }
    
    func populateMap(serverDict: Dictionary<String, Dictionary<String, Any>>) {
        blips.removeAll()
        lastAnnotations.removeAll()
        
        for (_, value) in serverDict {
            // Change these force casts, crash waiting to happen
            let dictEntry = (value as NSDictionary).mutableCopy() as! NSMutableDictionary
            
            let blipEntry = dictEntry as? [String: Any] ?? [:]
            
            if let blip = Blip(json: blipEntry) {
                blips.append(blip)
            }
            else {
                print("Failed to unwrap blip!")
                print(value)
                abort()
            }
        }
        
        let userLocation = CLLocationCoordinate2D(latitude: userLatitude, longitude: userLongitude)
        
        centerMapOnBlipCity(location: userLocation)
        
        for blip in blips {
            placePinForBlip(blip: blip)
        }
    }
    
    func locationDetermined() {
        self.gotUserLocation = true
    }
    
    func relayUserLogin(account: User) {
        signInModel.userLoggedIn(account: account)
        signInModel.addUserHistoryObserver(observer: lookupModel)
        signInModel.updateUserHistoryObservers()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        locManager.addLocationObserver(observer: self)
        locManager.getLocation(callback: { (coordinate) in self.locManager.getLocationCallback(coordinate: coordinate)})
        lookupModel.syncWithServer()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func blipRequestCallback(request: [String: Any], latitude: Double, longitude: Double) {
        self.userLatitude = latitude
        self.userLongitude = longitude
        
        do {
            //abstract up serverPostCallback from here and LookupModel
            try ServerInterface.postServer(jsonRequest: request, callback: { (data) in self.serverPostCallback(data: data) })
        } catch ServerInterfaceError.badJSONRequest(description: let error) {
            print(error)
        } catch {
            print("Other error")
        }
    }
    
    //MARK: Navigation
    @IBAction func unwindToBlipMap(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? LookupViewController {
            let selectedAttractions = sourceViewController.getSelectedAttractions()
            let openNow = sourceViewController.getOpenNowValue()
            let radius = sourceViewController.getRadiusValue()
            
            let customLookup = CustomLookup(attribute: selectedAttractions, openNow: openNow, radius: radius)
            
            let blipRequest = BlipRequest(inLookup: customLookup!, inUser: signInModel.getAccount(), locManager: locManager, callback: blipRequestCallback)
            
            blipRequest.JSONify()
        }
        
        if let sourceViewController = sender.source as? AccountViewController {
            let signedInStatus = sourceViewController.getSignInStatus()
            
            // If the user signs out, remove all blips from the map
            if signedInStatus == false {
                let allAnnotations = mapView.annotations
                mapView.removeAnnotations(allAnnotations)
            }
        }
    }
    
    // Triggered on "Cancel" bar button in SignInVC
    // Restore the annotations removed in segue preparation
    @IBAction func cancelToBlipMap(sender: UIStoryboardSegue) {
        mapView.addAnnotations(lastAnnotations)
        lastAnnotations.removeAll()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationNC = segue.destination as? UINavigationController {
            if let lookupVC = destinationNC.topViewController as? LookupViewController {
                // Clear current annotations (pins) on map
                // We save these annotations in case the user cancels the blip request
                // On cancellation, cancelToBlipMap is invoked and the annotations are restored
                lastAnnotations = mapView.annotations
                mapView.removeAnnotations(lastAnnotations)
                
                // need to reorder attractions in lookupModel by attraction history
                lookupVC.setLookupModel(inLookupModel: self.lookupModel)
                
                // Set lookupVC as an Observer of locManager so it knows when to
                // start allowing blip requests (i.e. enable "Done" button)
                locManager.addLocationObserver(observer: lookupVC)
                
                // If lookupVC is loaded after the location is found, we need to manually enable the button
                if (self.gotUserLocation == true) {
                    lookupVC.locationDetermined()
                }
            }
            
            if let accountVC = destinationNC.topViewController as? AccountViewController {
                accountVC.setSignInModel(inSignInModel: signInModel)
                
                signInModel.addUserAccountObserver(observer: accountVC)
            }
        }
    }
}
