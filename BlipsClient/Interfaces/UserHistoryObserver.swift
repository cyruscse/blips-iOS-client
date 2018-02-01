//
//  UserHistoryObserver.swift
//  BlipsClient
//
//  Created by Cyrus Sadeghi on 2018-01-26.
//  Copyright © 2018 Cyrus Sadeghi. All rights reserved.
//

import Foundation

protocol UserHistoryObserver {
    func historyUpdated(attractionHistory: [AttractionHistory])
}
