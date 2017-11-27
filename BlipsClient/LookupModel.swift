//
//  LookupModel.swift
//  BlipsClient
//
//  Created by Cyrus Sadeghi on 2017-11-24.
//  Copyright © 2017 Cyrus Sadeghi. All rights reserved.
//

import Foundation

class LookupModel {
    let attributesTag = "attributes"
    let attractionTypeTag = "attraction_types"
    let cityCountTag = "city_count"
    
    var numCities: Int = 0
    var attractionTypes = [String]()
    
    func parseAttributes(entry: [String: Any]) {
        guard let cityCount = entry[cityCountTag] as? Int
        else {
            print("City ID parse failed!")
            return
        }
        
        self.numCities = cityCount
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
    
    func syncWithServer() {
        let jsonRequest = ["requestType": "dbsync"]
        
        do {
            try ServerInterface.postServer(jsonRequest: jsonRequest, callback: { (data) in self.serverPostCallback(data: data) })
        } catch ServerInterfaceError.badJSONRequest(description: let error) {
            print(error)
        } catch {
            print("Other error")
        }
    }
}
