//
//  LookupModel.swift
//  BlipsClient
//
//  Created by Cyrus Sadeghi on 2017-11-24.
//  Copyright © 2017 Cyrus Sadeghi. All rights reserved.
//

// LookupModel is the model for LookupVC (VC -> ViewController). When the app is launched,
// it requests the list of attraction types from the server. When LookupVC is segued in, it receives its data from here

import Foundation
import MapKit

class LookupModel: UserHistoryObserver, LocationObserver {
    let attributesTag = "attributes"
    let attractionTypeTag = "attraction_types"

    // Attraction Types contains the list of attractions, sorted by user history
    private var allAttractionTypes = [String]()
    private var priorityAttractionTypes = [String]()
    private var properNames = [String]()
    private var userTypeQueryCount: Int = 0
    
    private var clientGoogleKey: String = ""
    
    // Attraction types as returned by Google are JSON readable (i.e. "grocery_or_supermarket" instead of Grocery Store)
    // These two dictionaries are translation tables between the two types
    private var attrToProperName = [String: String]()
    private var properNameToAttr = [String: String]()
    
    private var lookupObservers = [LookupModelObserver]()
    private var serverSyncComplete = false
    
    var lookupVC: LookupTableViewController?
    
    func addLookupObserver(observer: LookupModelObserver) {
        lookupObservers.append(observer)

        // If LookupVC is loaded after we have the attraction list (usual case),
        // we need to immediately notify all the observers (including LookupVC) that the list
        // of attraction types is ready.
        if serverSyncComplete == true {
            notifyAttractionTypesReady()
            notifyClientKeyReady()
        }
    }
    
    func notifyAttractionTypesReady() {
        serverSyncComplete = true
        
        for observer in lookupObservers {
            observer.setAttractionTypes(attrToProperName: attrToProperName, properNameToAttr: properNameToAttr, prioritySortedAttractions: priorityAttractionTypes, userTypeQueryCount: userTypeQueryCount)
        }
    }
    
    func notifyClientKeyReady() {
        for observer in lookupObservers {
            observer.gotGoogleClientKey(key: clientGoogleKey)
        }
    }

    func parseAttributes(entries: [String: Any]) {
        for (key, value) in entries {
            if (key == "client_key") {
                guard let clientKey = value as? String else {
                    print("Client key parse failed!")
                    return
                }
                
                self.clientGoogleKey = clientKey
            }
        }
    }
    
    // Parse the dictionary of attraction types returned from the server
    func parseAttractionTypes(entries: [String: Any]) {
        for (key, value) in entries {
            // As explained before, we have two names for the same type
            // "Name" is the JSON friendly name
            // "ProperName" is the readable name
            if (key == "Name") {
                guard let typeName = value as? String else {
                    print("Attraction Type parse failed!")
                    return
                }
             
                allAttractionTypes.append(typeName)
            }
            
            if (key == "ProperName") {
                guard let properName = value as? String else {
                    print("Attraction Proper Name parse failed!")
                    return
                }
                
                properNames.append(properName)
            }
        }

        // Set up the translation tables
        for (index, element) in allAttractionTypes.enumerated() {
            attrToProperName[element] = properNames[index]
        }
        
        for (index, element) in properNames.enumerated() {
            properNameToAttr[element] = allAttractionTypes[index]
        }
    }

    // When the attraction history counters change, update what displays in LookupVC
    // Attraction types are sorted by query frequency (types that haven't been queried are sorted alphabetically)
    // Part of the UserHistoryObserver protocol
    func historyUpdated(attractionHistory: [AttractionHistory]) {
        var attractionSet: Set<String> = Set(allAttractionTypes)
        
        priorityAttractionTypes = []
        properNames = []
        userTypeQueryCount = attractionHistory.count
        
        for entry in attractionHistory {
            attractionSet.remove(entry.attraction)
            priorityAttractionTypes.append(entry.attraction)
        }
        
        priorityAttractionTypes.append(contentsOf: attractionSet.sorted())
    }
    
    func locationDetermined(location: CLLocationCoordinate2D) {
        lookupVC?.locationDetermined(location: location, haveDeviceLocation: true)
    }

    // Callback function for Attraction Type reply
    func serverPostCallback(data: Data) {
        do {
            let responseContents = try ServerInterface.readJSON(data: data)
            
            for (key, value) in responseContents {
                let jsonContents = (value as! NSArray).mutableCopy() as! NSMutableArray
                
                for (jsonEntry) in jsonContents {
                    let entry = jsonEntry as? [String: Any] ?? [:]
                    
                    if (key == attributesTag) {
                        parseAttributes(entries: entry)
                    } else if (key == attractionTypeTag) {
                        parseAttractionTypes(entries: entry)
                    }
                }
            }
            
            if (priorityAttractionTypes.count == 0) {
                priorityAttractionTypes = allAttractionTypes
            }

            notifyAttractionTypesReady()
            notifyClientKeyReady()
        } catch ServerInterfaceError.JSONParseFailed(description: let error) {
            print(error)
        } catch {
            print("Attraction Type query failed")
        }
    }
    
    func syncWithServer() {
        let jsonRequest = ["requestType": "dbsync", "syncType": "getattractions"]
        
        ServerInterface.makeRequest(request: jsonRequest, callback: serverPostCallback)
    }
}
