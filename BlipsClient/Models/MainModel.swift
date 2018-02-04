//
//  MainModel.swift
//  BlipsClient
//
//  Created by Cyrus Sadeghi on 2018-02-02.
//  Copyright © 2018 Cyrus Sadeghi. All rights reserved.
//

// Main model class for BlipsClient. Instantiated in ViewController.swift.
// Instantiates all other model classes and delegates requests to those models.
// Sets up observer lists for most model classes, some observers are setup outside of here.

import Foundation
import MapKit

class MainModel {
    private let locManager = Location()
    private let lookupModel = LookupModel()
    private let signInModel = SignInModel()
    private let mapModel = MapModel()
    
    // SignInModel Methods
    
    // On Google user login, AppDelegate.swift calls ViewController which delegates here.
    // Let SignInModel know about the login and setup observers for the User object
    func relayUserLogin(account: User) {
        signInModel.userLoggedIn(account: account)
        signInModel.addUserHistoryObserver(observer: lookupModel)
        signInModel.updateUserHistoryObservers()
    }
    
    // When we segue from ViewController to AccountVC, AccountVC needs a direct reference to
    // SignInModel (explained in AccountVC). SignInModel also takes AccountVC as an observer (to update AccountVC's UI)
    func registerAccountVC(accountVC: AccountViewController) {
        accountVC.setSignInModel(signInModel: signInModel)
        signInModel.addUserAccountObserver(observer: accountVC)
    }
    
    // LookupModel Methods
    
    // On LookupVC confirming a lookup request, delegate the request to MapModel
    // Also update the user's attraction history through SignInModel
    func relayBlipLookup(lookupVC: LookupViewController) {
        mapModel.requestBlips(lookupVC: lookupVC, accountID: signInModel.getAccountID(), latitude: locManager.getLatitude(), longitude: locManager.getLongitude())
        signInModel.updateAttractionHistory(selections: lookupVC.getSelectedAttractions())
    }
    
    func registerLookupVC(lookupVC: LookupViewController) {
        // Account needs to know when Attraction Types are available
        // in order to set a prioritized list on app load
        lookupModel.addLookupObserver(observer: signInModel.getAccount())
        lookupModel.addLookupObserver(observer: lookupVC)
    
        // Set lookupVC as an Observer of locManager so it knows when to
        // start allowing blip requests (i.e. enable "Done" button)
        locManager.addLocationObserver(observer: lookupVC)
        locManager.forceUpdateObservers()
    }
    
    // MapModel methods
    
    // Register the map view as an observer of the map model
    func registerMapVC(mapVC: MapViewController) {
        mapModel.addObserver(observer: mapVC)
        mapVC.delegate = mapVC
        mapVC.register(BlipMarkerView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
    }
    
    // Remove annotations from the map, either on user sign out or when making a new request
    func clearMapVC(retainAnnotations: Bool) {
        if retainAnnotations == true || signInModel.isUserLoggedIn() == false {
            mapModel.clearMapVC(retainAnnotations: retainAnnotations)
        }
    }
    
    // Restore the map's annotations
    func restoreMapVC() {
        mapModel.restoreMapVC()
    }

    init() {
        signInModel.setLookupModel(lookupModel: lookupModel)
        signInModel.addUserAccountObserver(observer: mapModel)
        locManager.getLocation(callback: { (coordinate) in self.locManager.getLocationCallback(coordinate: coordinate) })
        lookupModel.syncWithServer()
    }
}
