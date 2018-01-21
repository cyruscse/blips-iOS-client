//
//  SignInModel.swift
//  BlipsClient
//
//  Created by Cyrus Sadeghi on 2018-01-21.
//  Copyright © 2018 Cyrus Sadeghi. All rights reserved.
//

import Foundation

class SignInModel: UserAccountObserver {
    var account: User!
    
    func userLoggedIn(account: User) {
        self.account = account
        syncWithServer()
    }
    
    func serverPostCallback(data: Data) {
        do {
            let responseContents = try ServerInterface.readJSON(data: data)
            
            for (key, value) in responseContents {
                /*let jsonContents = (value as! NSArray).mutableCopy() as! NSMutableArray
                
                for (jsonEntry) in jsonContents {
                    let entry = jsonEntry as? [String: Any] ?? [:]
                    
                    if (key == attributesTag) {
                        parseAttributes(entry: entry)
                    }
                    else if (key == attractionTypeTag) {
                        parseAttractionTypes(entries: entry)
                    }
                }*/
                print("\(key) \(value)")
            }
        } catch ServerInterfaceError.JSONParseFailed(description: let error) {
            print(error)
        } catch {
            print("Other error")
        }
    }
    
    // protocol this and serverPostCallback with LookupModel
    func syncWithServer() {
        let jsonRequest = ["requestType": "dbsync", "syncType": "login", "uid": account.getIdToken(), "name": account.getName(), "email": account.getEmail()]
        
        do {
            try ServerInterface.postServer(jsonRequest: jsonRequest, callback: { (data) in self.serverPostCallback(data: data) })
        } catch ServerInterfaceError.badJSONRequest(description: let error) {
            print(error)
        } catch {
            print("Other error")
        }
    }
}
