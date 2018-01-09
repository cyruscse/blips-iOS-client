//
//  CustomLookup.swift
//  BlipsClient
//
//  Created by Cyrus Sadeghi on 2017-11-27.
//  Copyright © 2017 Cyrus Sadeghi. All rights reserved.
//

import Foundation

struct CustomLookup {
    let attributeType: String
}

extension CustomLookup {
    init?(attribute: String) {
        self.attributeType = attribute
    }
}
