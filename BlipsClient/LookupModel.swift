//
//  LookupModel.swift
//  BlipsClient
//
//  Created by Cyrus Sadeghi on 2017-11-24.
//  Copyright © 2017 Cyrus Sadeghi. All rights reserved.
//

import Foundation

class LookupModel: UserHistoryObserver {
    let attributesTag = "attributes"
    let attractionTypeTag = "attraction_types"
    
    private var attractionTypes = [String]()
    
    func getAttractionTypes() -> [String] {
        return attractionTypes
    }
    
    func parseAttributes(entry: [String: Any]) {
        print("Nothing yet...")
    }
    
    func parseAttractionTypes(entries: [String: Any]) {
        for (key, value) in entries {
            if (key == "Name") {
               guard let typeName = value as? String
                else {
                    print("Attraction Type parse failed!")
                    return
                }
             
                self.attractionTypes.append(typeName)
            }
        }
    }
    
    // When the attraction history counters change, update what displays in LookupVC
    // Attraction types are sorted by query frequency (types that haven't been queried are sorted alphabetically)
    func historyUpdated(attractionHistory: [AttractionHistory]) {
        var attractionSet: Set<String> = Set(attractionTypes)
        attractionTypes = []
        
        for entry in attractionHistory {
            attractionSet.remove(entry.attraction)
            attractionTypes.append(entry.attraction)
        }
        
        attractionTypes.append(contentsOf: attractionSet.sorted())
    }
    
    func serverPostCallback(data: Data) {
        do {
            let responseContents = try ServerInterface.readJSON(data: data)
            
            for (key, value) in responseContents {
                let jsonContents = (value as! NSArray).mutableCopy() as! NSMutableArray
                
                for (jsonEntry) in jsonContents {
                    let entry = jsonEntry as? [String: Any] ?? [:]
                    
                    if (key == attributesTag) {
                        parseAttributes(entry: entry)
                    }
                    else if (key == attractionTypeTag) {
                        parseAttractionTypes(entries: entry)
                    }
                }
            }
        } catch ServerInterfaceError.JSONParseFailed(description: let error) {
            print(error)
        } catch {
            print("Other error")
        }
    }
    
    // this method matches syncWithServer in SignInModel, we can abstract this up (at least protocol)
    func syncWithServer() {
        let jsonRequest = ["requestType": "dbsync", "syncType": "getattractions"]
        
        do {
            try ServerInterface.postServer(jsonRequest: jsonRequest, callback: { (data) in self.serverPostCallback(data: data) })
        } catch ServerInterfaceError.badJSONRequest(description: let error) {
            print(error)
        } catch {
            print("Other error")
        }
    }
}
