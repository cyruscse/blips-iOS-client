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
    
    func relayUserLogin(account: User) {
        signInModel.userLoggedIn(account: account)
        signInModel.addUserHistoryObserver(observer: lookupModel)
        signInModel.updateUserHistoryObservers()
    }
    
    func registerLookupVC(lookupVC: LookupViewController) {
        lookupModel.addLookupObserver(observer: lookupVC)
        
        // Set lookupVC as an Observer of locManager so it knows when to
        // start allowing blip requests (i.e. enable "Done" button)
        locManager.addLocationObserver(observer: lookupVC)
    }
    
    func registerAccountVC(accountVC: AccountViewController) {
        accountVC.setSignInModel(signInModel: signInModel)
        signInModel.addUserAccountObserver(observer: accountVC)
    }

    init() {
        signInModel.setLookupModel(lookupModel: lookupModel)
        signInModel.addUserAccountObserver(observer: mapModel)
        locManager.getLocation(callback: { (coordinate) in self.locManager.getLocationCallback(coordinate: coordinate) })
        lookupModel.syncWithServer()
    }
}
