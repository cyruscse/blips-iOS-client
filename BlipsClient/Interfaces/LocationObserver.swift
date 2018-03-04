//
//  LocationObserver.swift
//  BlipsClient
//
//  Created by Cyrus Sadeghi on 2018-01-22.
//  Copyright © 2018 Cyrus Sadeghi. All rights reserved.
//

import Foundation
import CoreLocation

protocol LocationObserver {
    func locationDetermined(location: CLLocationCoordinate2D)
}
