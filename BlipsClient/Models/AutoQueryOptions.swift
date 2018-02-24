//
//  AutoQueryOptions.swift
//  BlipsClient
//
//  Created by Cyrus Sadeghi on 2018-02-23.
//  Copyright © 2018 Cyrus Sadeghi. All rights reserved.
//

import Foundation

class AutoQueryOptions: NSObject, NSCoding {
    var autoQueryEnabled: Bool
    var autoQueryTypeGrabLength: Int
    var autoQueryOpenNow: Bool
    var autoQueryRating: Double
    var autoQueryPriceRange: Int
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(autoQueryEnabled, forKey: "autoQueryEnabled")
        aCoder.encode(autoQueryTypeGrabLength, forKey: "autoQueryTypeGrabLength")
        aCoder.encode(autoQueryOpenNow, forKey: "autoQueryOpenNow")
        aCoder.encode(autoQueryRating, forKey: "autoQueryRating")
        aCoder.encode(autoQueryPriceRange, forKey: "autoQueryPriceRange")
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.autoQueryEnabled = aDecoder.decodeBool(forKey: "autoQueryEnabled")
        self.autoQueryTypeGrabLength = aDecoder.decodeInteger(forKey: "autoQueryTypeGrabLength")
        self.autoQueryOpenNow = aDecoder.decodeBool(forKey: "autoQueryOpenNow")
        self.autoQueryRating = aDecoder.decodeDouble(forKey: "autoQueryRating")
        self.autoQueryPriceRange = aDecoder.decodeInteger(forKey: "autoQueryPriceRange")
    }
    
    init(autoQueryEnabled: Bool, autoQueryTypeGrabLength: Int, autoQueryOpenNow: Bool, autoQueryRating: Double, autoQueryPriceRange: Int) {
        self.autoQueryEnabled = autoQueryEnabled
        self.autoQueryTypeGrabLength = autoQueryTypeGrabLength
        self.autoQueryOpenNow = autoQueryOpenNow
        self.autoQueryRating = autoQueryRating
        self.autoQueryPriceRange = autoQueryPriceRange
    }
    
    convenience override init() {
        self.init(autoQueryEnabled: true, autoQueryTypeGrabLength: 0, autoQueryOpenNow: true, autoQueryRating: 0.0, autoQueryPriceRange: 0)
    }
}
