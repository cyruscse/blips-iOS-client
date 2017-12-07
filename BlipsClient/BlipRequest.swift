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
let queryTag = "query"
let latitudeTag = "latitude"
let longitudeTag = "longitude"
let attractionTypeTag = "type"
let radiusTag = "radius"
let openNowTag = "openNow"

struct BlipRequest {
    let lookup: CustomLookup
}

extension BlipRequest {
    init?(inLookup: CustomLookup) {
        self.lookup = inLookup
    }
    
    func JSONify() -> [String: String] {
        let toReturn = [requestTypeTag: queryTag, latitudeTag: "40.7101898", longitudeTag: "-74.0079269", attractionTypeTag: self.lookup.attributeType, radiusTag: "400", openNowTag: "true"]
        
        return toReturn
    }
}
