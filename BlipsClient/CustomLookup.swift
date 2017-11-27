//
//  CustomLookup.swift
//  BlipsClient
//
//  Created by Cyrus Sadeghi on 2017-11-27.
//  Copyright © 2017 Cyrus Sadeghi. All rights reserved.
//

import Foundation

struct CustomLookup {
    let cityID: Int
    let attributeType: String
}

extension CustomLookup {
    init?(city: Int, attribute: String) {
        self.cityID = city
        self.attributeType = attribute
    }
}
