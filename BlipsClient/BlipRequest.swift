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
let cityIDTag = "cityID"
let attractionTypeTag = "type"

struct BlipRequest {
    let lookup: CustomLookup
}

extension BlipRequest {
    init?(inLookup: CustomLookup) {
        self.lookup = inLookup
    }
    
    func JSONify() -> [String: String] {
        let toReturn = [requestTypeTag: queryTag, cityIDTag: String(self.lookup.cityID), attractionTypeTag: self.lookup.attributeType]
        
        return toReturn
    }
}
