//
//  SignInModel.swift
//  BlipsClient
//
//  Created by Cyrus Sadeghi on 2018-01-21.
//  Copyright © 2018 Cyrus Sadeghi. All rights reserved.
//

import Foundation

class SignInModel: UserAccountObserver {
    let userIdTag = "userID"
    private var account: User!
    private var loggedIn: Bool = false
    
    func userLoggedIn(account: User) {
        self.loggedIn = true
        self.account = account
        syncWithServer()
    }
    
    func userLoggedOut() {
        self.loggedIn = false
    }
    
    func isUserLoggedIn() -> Bool {
        return self.loggedIn
    }
    
    func getAccount() -> User {
        return self.account;
    }
    
    func serverPostCallback(data: Data) {
        do {
            let responseContents = try ServerInterface.readJSON(data: data)
            
            for (key, value) in responseContents {
                if (key == userIdTag) {
                    account.setID(userID: value as! Int)
                }
                else {
                    account.addAttractionHistory(attraction: key, frequency: value as! Int)
                }
            }
        } catch ServerInterfaceError.JSONParseFailed(description: let error) {
            print(error)
        } catch {
            print("Other error")
        }
    }
    
    // protocol this and serverPostCallback with LookupModel
    func syncWithServer() {
        let jsonRequest = ["requestType": "dbsync", "syncType": "login", "name": account.getName(), "email": account.getEmail()]
        
        do {
            try ServerInterface.postServer(jsonRequest: jsonRequest, callback: { (data) in self.serverPostCallback(data: data) })
        } catch ServerInterfaceError.badJSONRequest(description: let error) {
            print(error)
        } catch {
            print("Other error")
        }
    }
}
