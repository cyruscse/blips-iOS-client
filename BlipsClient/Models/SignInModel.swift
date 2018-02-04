//
//  SignInModel.swift
//  BlipsClient
//
//  Created by Cyrus Sadeghi on 2018-01-21.
//  Copyright © 2018 Cyrus Sadeghi. All rights reserved.
//

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
    let deleteUserTag = "deleteUser"
    let nameTag = "name"
    let emailTag = "email"
    let okTag = "OK"
    
    private var lookupModel: LookupModel!
    private var account: User!
    private var loggedIn: Bool = false
    private var userAccountObservers = [UserAccountObserver]()
    
    init() {
        self.userLoaded(loaded: NSKeyedUnarchiver.unarchiveObject(withFile: User.ArchiveURL.path) as? User ?? nil)
    }

    func addUserAccountObserver(observer: UserAccountObserver) {
        userAccountObservers.append(observer)
        
        if loggedIn == true {
            notifyUserLoggedIn()
        }
    }
    
    func setLookupModel(lookupModel: LookupModel) {
        self.lookupModel = lookupModel
        account.addUserHistoryObserver(observer: lookupModel)
    }
    
    func guestUserLogin() {
        account = User(firstName: "", lastName: "", imageURL: URL(string: ".")!, email: "", userID: -1, attractionHistory: [:], guest: true)
        
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
        for observer in userAccountObservers {
            observer.userLoggedIn(account: account)
        }
    }
    
    func userLoaded(loaded: User?) {
        if (loaded == nil) {
            guestUserLogin()
        }
        else {
            self.account = loaded
            
            self.loggedIn = true
            
            notifyUserLoggedIn()
        }
    }
    
    func userLoggedIn(account: User) {
        self.loggedIn = true
        self.account = account
        
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
        
        self.account.clearAttractionHistory()
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
    
    func serverLoginCallback(data: Data) {
        do {
            let responseContents = try ServerInterface.readJSON(data: data)
            var serverAttractionHistory: [String: Int] = [:]
            
            for (key, value) in responseContents {
                if (key == userIdTag) {
                    account.setID(userID: value as! Int)
                    account.saveUser()
                }
                else if (key != statusTag) {
                    serverAttractionHistory[key] = value as? Int
                }
            }
            
            // Defer updating attraction history until the whole response is parsed
            // setAttractionHistory calls User observers
            if serverAttractionHistory.count != 0 {
                account.setAttractionHistory(history: serverAttractionHistory)
            }
        } catch ServerInterfaceError.JSONParseFailed(description: let error) {
            print(error)
        } catch {
            print("Other error")
        }
    }
    
    func serverDeleteClearCallback(data: Data) {
        do {
            let responseContents = try ServerInterface.readJSON(data: data)
            
            for (key, value) in responseContents {
                if (key == statusTag) {
                    if let strValue = value as? String {
                        if strValue != okTag {
                            print("Failed to clear server history")
                        }
                    }
                }
            }
        } catch ServerInterfaceError.JSONParseFailed(description: let error) {
            print(error)
        } catch {
            print("Other error")
        }
    }
    
    // protocol this and serverPostCallback with LookupModel
    func serverLogin() {
        let jsonRequest = [requestTypeTag: dbSyncTag, syncTypeTag: loginTag, nameTag: account.getName(), emailTag: account.getEmail()]
        
        // issue #14, this is duplicated a few times
        do {
            try ServerInterface.postServer(jsonRequest: jsonRequest, callback: { (data) in self.serverLoginCallback(data: data) })
        } catch ServerInterfaceError.badJSONRequest(description: let error) {
            print(error)
        } catch {
            print("Other error")
        }
    }
    
    func clearAttractionHistory() {
        account.clearAttractionHistory()
        
        let jsonRequest = [requestTypeTag: dbSyncTag, syncTypeTag: clearHistoryTag, userIdTag: String(account.getID())]
        
        // issue #14
        do {
            try ServerInterface.postServer(jsonRequest: jsonRequest, callback: { (data) in self.serverDeleteClearCallback(data: data) })
        } catch ServerInterfaceError.badJSONRequest(description: let error) {
            print(error)
        } catch {
            print("Other error")
        }
    }

    func deleteServerUser(id: Int) {
        let jsonRequest = [requestTypeTag: dbSyncTag, syncTypeTag: deleteUserTag, userIdTag: String(id)]
        
        // issue #14
        do {
            try ServerInterface.postServer(jsonRequest: jsonRequest, callback: { (data) in self.serverDeleteClearCallback(data: data) })
        } catch ServerInterfaceError.badJSONRequest(description: let error) {
            print(error)
        } catch {
            print("Other error")
        }
    }
}
