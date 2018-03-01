//
//  SignInModel.swift
//  BlipsClient
//
//  Created by Cyrus Sadeghi on 2018-01-21.
//  Copyright © 2018 Cyrus Sadeghi. All rights reserved.
//

// SignInModel handles everything to do with User objects.

import Foundation
import GoogleSignIn

class SignInModel {
    let userIdTag = "userID"
    let statusTag = "status"
    let requestTypeTag = "requestType"
    let dbSyncTag = "dbsync"
    let syncTypeTag = "syncType"
    let loginTag = "login"
    let clearHistoryTag = "clearHistory"
    let setHistoryTag = "setHistory"
    let deleteUserTag = "deleteUser"
    let nameTag = "name"
    let emailTag = "email"
    let historyTag = "history"
    let autoQueryOptionsTag = "autoQueryOptions"
    let updateAutoQueryOptionsTag = "updateAutoQueryOptions"
    let enabledTag = "enabled"
    let typeGrabLengthTag = "typeGrabLength"
    let openNowTag = "openNow"
    let ratingTag = "rating"
    let priceRangeTag = "priceRange"
    let optionsTag = "options"
    let savedBlipsTag = "savedBlips"
    let serverSaveBlipTag = "saveBlip"
    let serverUnSaveBlipTag = "unsaveBlip"
    let blipIDTag = "blipID"
    let okTag = "OK"
    
    private var lookupModel: LookupModel!
    private var account: User!
    private var replacedGuest: User!
    private var loggedIn: Bool = false
    private var userAccountObservers = [UserAccountObserver]()
    
    init() {
        self.userLoaded(loaded: NSKeyedUnarchiver.unarchiveObject(withFile: User.ArchiveURL.path) as? User ?? nil)
    }

    func addUserAccountObserver(observer: UserAccountObserver) {
        userAccountObservers.append(observer)
        
        if loggedIn == true {
            observer.userLoggedIn(account: account)
        }
    }
    
    func setLookupModel(lookupModel: LookupModel) {
        self.lookupModel = lookupModel
        account.addUserHistoryObserver(observer: lookupModel)
    }
    
    func guestUserLogin() {
        account = User()
        account.signInModel = self
        
        // lookupModel can be nil here on the app's first ever launch
        // No User info has been saved to disk, so we fall back to a guestLogin,
        // but at this point lookupModel hasn't been initialized yet.
        // When setLookupModel is called, we'll add it as an observer to this User
        if lookupModel != nil {
            account.addUserHistoryObserver(observer: lookupModel)
        }
        
        self.loggedIn = true
        
        for observer in userAccountObservers {
            observer.userLoggedIn(account: account)
        }
    }
    
    func notifyUserLoggedIn() {
        DispatchQueue.main.async {
            print("async")
            for observer in self.userAccountObservers {
                observer.userLoggedIn(account: self.account)
            }
        }
    }
    
    func userLoaded(loaded: User?) {
        if (loaded == nil) {
            guestUserLogin()
        }
        else {
            self.account = loaded
            self.account.signInModel = self
            self.loggedIn = true
            
            notifyUserLoggedIn()
        }
    }
    
    func notifyGuestReplaced(guestQueried: Bool) {
        for observer in userAccountObservers {
            observer.guestReplaced(guestQueried: guestQueried)
        }
    }
    
    func mergeGuestHistory() {
        self.account.mergeAttractionHistory(toMerge: self.replacedGuest.getAttractionHistory(), savedToMerge: self.replacedGuest.savedBlips)
        self.account.setAutoQueryOptions(options: self.replacedGuest.autoQueryOptions)
        self.setServerHistory(history: self.account.getAttractionHistory())
        self.updateServerAutoQueryOptions(enabled: self.account.autoQueryOptions.autoQueryEnabled, typeGrabLength: self.account.autoQueryOptions.autoQueryTypeGrabLength, openNow: self.account.autoQueryOptions.autoQueryOpenNow, rating: self.account.autoQueryOptions.autoQueryRating, priceRange: self.account.autoQueryOptions.autoQueryPriceRange)
        self.replacedGuest = nil
    }
    
    func userLoggedIn(account: User) {
        if loggedIn == true && self.account.isGuest() == true {
            var guestQueried = false
            
            if account.getAttractionHistoryCount() != 0 {
                guestQueried = true
            }
            
            replacedGuest = self.account
            notifyGuestReplaced(guestQueried: guestQueried)
        }
        
        account.signInModel = self
        self.loggedIn = true
        self.account = account
        
        retrieveSavedBlipMetadata()
        serverLogin()
        notifyUserLoggedIn()
    }
    
    func userLoggedOut(deleteUser: Bool) {
        self.loggedIn = false
        
        GIDSignIn.sharedInstance().signOut()
        
        for observer in userAccountObservers {
            observer.userLoggedOut()
        }

        if FileManager().fileExists(atPath: User.ArchiveURL.path) {
            do {
                try FileManager().removeItem(atPath: User.ArchiveURL.path)
            } catch let error as NSError {
                print("Failed to delete user: \(error.localizedDescription)")
            }
        }
        
        if deleteUser == true {
            deleteServerUser(id: account.getID())
        }
        
        self.account.clearAttractionHistoryAndSettings()
        self.account = nil
        
        guestUserLogin()
    }
    
    func isUserLoggedIn() -> Bool {
        return self.loggedIn
    }
    
    func getAccount() -> User {
        return self.account
    }
    
    func userIsGuest() -> Bool {
        return self.account.isGuest()
    }
    
    func addUserHistoryObserver(observer: UserHistoryObserver) {
        account.addUserHistoryObserver(observer: observer)
    }
    
    func updateUserHistoryObservers() {
        account.updateHistoryListeners()
    }
    
    func updateAttractionHistory(selections: [String]) {
        account.updateAttractionHistory(selections: selections)
    }
    
    func getAccountID() -> Int {
        return account.getID()
    }
    
    func userSavedBlip(placeID: String) -> Bool {
        return account.blipIsSaved(placeID: placeID)
    }
    
    func connectBlipDetailVC(detailVC: BlipDetailViewController) {
        detailVC.addObserver(observer: account)
    }
    
    func retrieveSavedBlipMetadata() {
        for blip in account.savedBlips {
            blip.requestPhotoMetadata()
        }
    }
    
    func apiKeyProvided() {
        retrieveSavedBlipMetadata()
    }
    
    func serverLoginCallback(data: Data) {
        do {
            let responseContents = try ServerInterface.readJSON(data: data)
            var serverAttractionHistory: [String: Int] = [:]
            var autoQueryOptions: AutoQueryOptions!
            var savedBlips = [Blip]()
            
            for (key, value) in responseContents {
                if (key == userIdTag) {
                    let accountIDArray = value as! [Int]
                    account.setID(userID: accountIDArray.first!)
                    account.saveUser()
                } else if (key == statusTag) {
                    let status = value as! [String]
                    
                    if (status.first != okTag) {
                        let alert = AnywhereUIAlertController(title: "Login Failed", message: "The server rejected your login request.", preferredStyle: .alert);
                        alert.show();
                        print("bad login")
                        
                        return
                    }
                } else if (key == historyTag) {
                    let attractionHistoryArray = value as! [[String: Int]]
                    
                    for entry in attractionHistoryArray {
                        // Only one entry in this dict
                        for (attraction, frequency) in entry {
                            serverAttractionHistory[attraction] = frequency
                        }
                    }
                } else if (key == autoQueryOptionsTag) {
                    let autoQueryOptionsArray = value as! [[String: Any]]
                    var enabledValue: Bool!
                    var typeGrabLengthValue: Int!
                    var openNowValue: Bool!
                    var ratingValue: Double!
                    var priceRangeValue: Int!
                    
                    for entry in autoQueryOptionsArray {
                        for (option, setting) in entry {
                            switch (option) {
                            case enabledTag:
                                enabledValue = setting as! Bool
                            case typeGrabLengthTag:
                                typeGrabLengthValue = setting as! Int
                            case openNowTag:
                                openNowValue = setting as! Bool
                            case ratingTag:
                                ratingValue = setting as! Double
                            case priceRangeTag:
                                priceRangeValue = setting as! Int
                            default:
                                let alert = AnywhereUIAlertController(title: "Login Failed", message: "The server returned invalid data.", preferredStyle: .alert);
                                alert.show();
                                print("login failed")
                                
                                return
                            }
                        }
                    }
                    
                    if enabledValue == nil || typeGrabLengthValue == nil || openNowValue == nil || ratingValue == nil || priceRangeValue == nil {
                        let alert = AnywhereUIAlertController(title: "Login Failed", message: "The server didn't return all required data.", preferredStyle: .alert);
                        alert.show();
                        print("login missing data")
                        
                        return
                    }
                    
                    autoQueryOptions = AutoQueryOptions(autoQueryEnabled: enabledValue, autoQueryTypeGrabLength: typeGrabLengthValue, autoQueryOpenNow: openNowValue, autoQueryRating: ratingValue, autoQueryPriceRange: priceRangeValue)
                } else if (key == savedBlipsTag) {
                    let savedBlipsArray = value as! [[String: Any]]
                    
                    for entry in savedBlipsArray {
                        if let blip = Blip(json: entry) {
                            savedBlips.append(blip)
                        } else {
                            let alert = AnywhereUIAlertController(title: "Blip Retrieval Failed", message: "The server didn't send blips in the correct format.", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in }))
                            alert.show()
                            print("bad blip format")
                            
                            return
                        }
                    }
                }
            }
            
            // Defer updating attraction history until the whole response is parsed
            // setAttractionHistory calls User observers
            if serverAttractionHistory.count != 0 {
                account.setAttractionHistory(history: serverAttractionHistory)
            }
            
            if savedBlips.count != 0 {
                account.setSavedBlips(savedBlips: savedBlips)
            }
            
            account.setAutoQueryOptions(options: autoQueryOptions)
            notifyUserLoggedIn()
        } catch ServerInterfaceError.JSONParseFailed(description: let error) {
            print(error)
        } catch {
            print("User login failed")
        }
    }
    
    func serverSyncCallback(data: Data) {
        do {
            let responseContents = try ServerInterface.readJSON(data: data)
            
            for (key, value) in responseContents {
                if (key == statusTag) {
                    if let strValue = value as? String {
                        if strValue != okTag {
                            let alert = AnywhereUIAlertController(title: "Server Sync Failed", message: "Client information couldn't be synced to the server.", preferredStyle: .alert);
                            alert.show();
                            print("couldn't sync to server")
                            
                            return
                        }
                    }
                }
            }
        } catch ServerInterfaceError.JSONParseFailed(description: let error) {
            print(error)
        } catch {
            print("Failed to sync to server")
        }
    }
    
    func serverLogin() {
        let jsonRequest = [requestTypeTag: dbSyncTag, syncTypeTag: loginTag, nameTag: account.getName(), emailTag: account.getEmail()]
        
        ServerInterface.makeRequest(request: jsonRequest, callback: serverLoginCallback)
    }
    
    func clearAttractionHistory() {
        account.clearAttractionHistoryAndSettings()
        
        let jsonRequest = [requestTypeTag: dbSyncTag, syncTypeTag: clearHistoryTag, userIdTag: String(account.getID())]
        
        ServerInterface.makeRequest(request: jsonRequest, callback: serverSyncCallback)
    }

    func deleteServerUser(id: Int) {
        let jsonRequest = [requestTypeTag: dbSyncTag, syncTypeTag: deleteUserTag, userIdTag: String(id)]
        
        ServerInterface.makeRequest(request: jsonRequest, callback: serverSyncCallback)
    }
    
    func setServerHistory(history: [String: Int]) {
        if history.count == 0 {
            return
        }
        
        let jsonRequest = [requestTypeTag: dbSyncTag, syncTypeTag: setHistoryTag, userIdTag: String(account.getID()), historyTag: history.description]
        
        ServerInterface.makeRequest(request: jsonRequest, callback: serverSyncCallback)
    }
    
    func updateServerAutoQueryOptions(enabled: Bool?, typeGrabLength: Int?, openNow: Bool?, rating: Double?, priceRange: Int?) {
        if account.isGuest() {
            return
        }
        
        var autoQueryOptionsArray = [[String: String]]()
        
        if enabled != nil {
            autoQueryOptionsArray.append([enabledTag : String(enabled!)])
        }
        
        if typeGrabLength != nil {
            autoQueryOptionsArray.append([typeGrabLengthTag: String(typeGrabLength!)])
        }
        
        if openNow != nil {
            autoQueryOptionsArray.append([openNowTag: String(openNow!)])
        }
        
        if rating != nil {
            autoQueryOptionsArray.append([ratingTag: String(rating!)])
        }
        
        if priceRange != nil {
            autoQueryOptionsArray.append([priceRangeTag: String(priceRange!)])
        }
        
        if autoQueryOptionsArray.count == 0 {
            return
        }
        
        let jsonRequest = [requestTypeTag: dbSyncTag, syncTypeTag: updateAutoQueryOptionsTag, userIdTag: String(account.getID()), optionsTag: autoQueryOptionsArray] as [String: Any]
        
        ServerInterface.makeRequest(request: jsonRequest, callback: serverSyncCallback)
    }
    
    func serverSaveBlip(blip: Blip, save: Bool) {
        if account.isGuest() {
            return
        }
        
        var syncTag: String!
        
        if save == true {
            syncTag = serverSaveBlipTag
        } else {
            syncTag = serverUnSaveBlipTag
        }
        
        let jsonRequest = [requestTypeTag: dbSyncTag, syncTypeTag: syncTag, userIdTag: String(account.getID()), blipIDTag: blip.placeID] as [String: Any]
                
        ServerInterface.makeRequest(request: jsonRequest, callback: serverSyncCallback)
    }
}
