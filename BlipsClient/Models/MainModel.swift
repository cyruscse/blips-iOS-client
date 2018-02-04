//
//  MainModel.swift
//  BlipsClient
//
//  Created by Cyrus Sadeghi on 2018-02-02.
//  Copyright © 2018 Cyrus Sadeghi. All rights reserved.
//

import Foundation

class MainModel {
    private let locManager = Location()
    private let lookupModel = LookupModel()
    private let signInModel = SignInModel()
    private let mapModel = MapModel()
    
    // SignInModel Methods
    func relayUserLogin(account: User) {
        signInModel.userLoggedIn(account: account)
        signInModel.addUserHistoryObserver(observer: lookupModel)
        signInModel.updateUserHistoryObservers()
    }
    
    func registerAccountVC(accountVC: AccountViewController) {
        accountVC.setSignInModel(signInModel: signInModel)
        signInModel.addUserAccountObserver(observer: accountVC)
    }
    
    // LookupModel Methods
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
    func registerMapVC(mapVC: MapViewController) {
        mapModel.addObserver(observer: mapVC)
    }
    
    func clearMapVC(retainAnnotations: Bool) {
        if retainAnnotations == true || signInModel.isUserLoggedIn() == false {
            mapModel.clearMapVC(retainAnnotations: retainAnnotations)
        }
    }
    
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
