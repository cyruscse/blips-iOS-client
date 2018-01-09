//
//  BlipRequest.swift
//  BlipsClient
//
//  Created by Cyrus Sadeghi on 2017-11-27.
//  Copyright © 2017 Cyrus Sadeghi. All rights reserved.
//

import Foundation
import CoreLocation

// Abstract this up??? (maybe a protocol)
let requestTypeTag = "requestType"
let queryTag = "query"
let latitudeTag = "latitude"
let longitudeTag = "longitude"
let attractionTypeTag = "types"
let radiusTag = "radius"
let openNowTag = "openNow"

class BlipRequest {
    let lookup: CustomLookup
    let locManager: Location
    
    private var latitude: Double
    private var longitude: Double
    
    init?(inLookup: CustomLookup, locManager: Location) {
        self.lookup = inLookup
        self.locManager = locManager
        
        self.latitude = 0.0
        self.longitude = 0.0
        
        locManager.getLocation(callback: { (coordinate) in self.locationCallback(coordinate: coordinate) })
    }
    
    func locationCallback (coordinate: CLLocationCoordinate2D) {
        print("loc callback \(coordinate.latitude) \(coordinate.longitude)")
        
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
    }
    
    func JSONify() -> [String: String] {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        
        // Cast Doubles to NSNumbers
        let latNum = NSNumber(value: self.latitude)
        let lngNum = NSNumber(value: self.longitude)
        
        // Format NSNumbers as Strings
        let latStr = numberFormatter.string(from: latNum) ?? "error"
        let lngStr = numberFormatter.string(from: lngNum) ?? "error"
        
        let toReturn = [requestTypeTag: queryTag, latitudeTag: latStr, longitudeTag: lngStr, attractionTypeTag: self.lookup.attributeType, radiusTag: "6000", openNowTag: "true"]
        
        return toReturn
    }
}
