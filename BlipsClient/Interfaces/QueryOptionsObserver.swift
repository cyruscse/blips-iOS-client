//
//  QueryOptionsObserver.swift
//  BlipsClient
//
//  Created by Cyrus Sadeghi on 2018-02-23.
//  Copyright © 2018 Cyrus Sadeghi. All rights reserved.
//

import Foundation

protocol QueryOptionsObserver {
    func attractionTypesChanged(value: Int)
    func autoQueryStatusChanged(enabled: Bool)
    func openNowChanged(value: Bool)
    func ratingChanged(rating: Double)
    func priceChanged(price: Int)
}
