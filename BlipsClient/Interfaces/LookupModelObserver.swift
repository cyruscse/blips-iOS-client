//
//  LookupModelObserver.swift
//  BlipsClient
//
//  Created by Cyrus Sadeghi on 2018-02-03.
//  Copyright © 2018 Cyrus Sadeghi. All rights reserved.
//

import Foundation

protocol LookupModelObserver {
    func setAttractionTypes(attrToProperName: [String: String], properNameToAttr: [String: String], prioritySortedAttractions: [String])
}
