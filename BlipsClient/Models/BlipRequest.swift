//
//  BlipRequest.swift
//  BlipsClient
//
//  Created by Cyrus Sadeghi on 2017-11-27.
//  Copyright © 2017 Cyrus Sadeghi. All rights reserved.
//

import Foundation

// Abstract this up??? (maybe a protocol)
let requestTypeTag = "requestType"
let userIDTag = "userID"
let queryTag = "query"
let latitudeTag = "latitude"
let longitudeTag = "longitude"
let attractionTypeTag = "types"
let radiusTag = "radius"
let openNowTag = "openNow"

class BlipRequest {
    private let lookup: CustomLookup
    private var accountID: Int
    private var latitude: Double
    private var longitude: Double
    
    init (inLookup: CustomLookup, accountID: Int, latitude: Double, longitude: Double) {
        self.lookup = inLookup
        self.accountID = accountID
        self.latitude = latitude
        self.longitude = longitude
    }
    
    func JSONify() -> [String: Any] {
        // If locManager hasn't determined the user's location yet, we can't make a request.
        // We shouldn't fall into this in the first place as the UI will block requests,
        // but we'll keep it just in case
        if (self.latitude == 0.0 || self.longitude == 0.0) {
            return [:]
        }
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.minimumFractionDigits = 8
        
        // Cast Doubles to NSNumbers
        let latNum = NSNumber(value: self.latitude)
        let lngNum = NSNumber(value: self.longitude)
        
        // Format NSNumbers as Strings
        let latStr = numberFormatter.string(from: latNum) ?? "error"
        let lngStr = numberFormatter.string(from: lngNum) ?? "error"
        
        let selectedAttributes = self.lookup.getAttributes()
        let openNow = self.lookup.getOpenNow()
        let radius = self.lookup.getRadius()
                
        return [requestTypeTag: queryTag, userIDTag: accountID, latitudeTag: latStr, longitudeTag: lngStr, attractionTypeTag: selectedAttributes, radiusTag: radius, openNowTag: openNow] as [String : Any]
    }
}
