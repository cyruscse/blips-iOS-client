//
//  BlipRequest.swift
//  BlipsClient
//
//  Created by Cyrus Sadeghi on 2017-11-27.
//  Copyright © 2017 Cyrus Sadeghi. All rights reserved.
//

// Create a query request for the server
//
// Used by MapModel. Given the client's location, account ID, radius to search in, and list of attraction types,
// create a JSON request. An example of the returned output is available in the blips-server repository

import Foundation

let requestTypeTag = "requestType"
let userIDTag = "userID"
let queryTag = "query"
let latitudeTag = "latitude"
let longitudeTag = "longitude"
let attractionTypeTag = "types"
let radiusTag = "radius"
let openNowTag = "openNow"
let priceTag = "maxPrice"
let ratingTag = "minRating"

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
        
        // Set up the NumberFormatter (used to cast the latitude/longitude from Double to String)
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.minimumFractionDigits = 8
        
        // Cast Doubles to NSNumbers
        let latNum = NSNumber(value: self.latitude)
        let lngNum = NSNumber(value: self.longitude)
        
        // Format NSNumbers as Strings
        let latStr = numberFormatter.string(from: latNum) ?? "error"
        let lngStr = numberFormatter.string(from: lngNum) ?? "error"
        
        // Get the list of attraction types to search for, radius to search in, and openNow value
        let selectedAttributes = self.lookup.getAttributes()
        let openNow = self.lookup.getOpenNow()
        let radius = self.lookup.getRadius()
        let priceRange = self.lookup.getPriceRange()
        let minimumRating = self.lookup.getMinimumRating()
                
        return [requestTypeTag: queryTag, userIDTag: accountID, latitudeTag: latStr, longitudeTag: lngStr, attractionTypeTag: selectedAttributes, radiusTag: radius,  ratingTag: minimumRating, priceTag: priceRange, openNowTag: openNow] as [String : Any]
    }
}
