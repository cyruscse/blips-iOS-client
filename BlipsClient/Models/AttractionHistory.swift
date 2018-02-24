//
//  AttractionHistory.swift
//  BlipsClient
//
//  Created by Cyrus Sadeghi on 2018-02-23.
//  Copyright © 2018 Cyrus Sadeghi. All rights reserved.
//

import Foundation

struct AttractionHistory: Comparable, Hashable {
    static func <(lhs: AttractionHistory, rhs: AttractionHistory) -> Bool {
        return lhs.frequency > rhs.frequency
    }
    
    static func ==(lhs: AttractionHistory, rhs: AttractionHistory) -> Bool {
        return lhs.attraction == rhs.attraction
    }
    
    var attraction: String
    let frequency: Int
    
    var hashValue: Int {
        return attraction.hashValue
    }
}
