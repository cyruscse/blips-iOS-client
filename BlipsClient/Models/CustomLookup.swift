//
//  CustomLookup.swift
//  BlipsClient
//
//  Created by Cyrus Sadeghi on 2017-11-27.
//  Copyright © 2017 Cyrus Sadeghi. All rights reserved.
//

// Used by MapModel and BlipRequest.
// Packages a request's attraction types, radius and openNow to one struct

import Foundation

struct CustomLookup {
    private let attributeType: [String]
    private let openNow: Bool
    private let radius: Int
}

extension CustomLookup {
    init?(attribute: [String], openNow: Bool, radius: Int) {
        self.attributeType = attribute
        self.openNow = openNow
        self.radius = radius
    }
    
    func getAttributes() -> [String] {
        return attributeType
    }
    
    func getOpenNow() -> Bool {
        return openNow
    }
    
    func getRadius() -> Int {
        return radius
    }
}
