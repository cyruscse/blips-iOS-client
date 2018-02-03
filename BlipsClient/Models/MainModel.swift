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
    
    init() {
        signInModel.setLookupModel(lookupModel: lookupModel)
        signInModel.addUserAccountObserver(observer: mapModel)
        locManager.getLocation(callback: { (coordinate) in self.locManager.getLocationCallback(coordinate: coordinate) })
        locManager.addLocationObserver(observer: lookupModel)
        lookupModel.syncWithServer()
    }
}
