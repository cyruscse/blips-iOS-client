//
//  LocationObserver.swift
//  BlipsClient
//
//  Created by Cyrus Sadeghi on 2018-01-22.
//  Copyright © 2018 Cyrus Sadeghi. All rights reserved.
//

import Foundation
import CoreLocation

//this might be a bad solution, if a new VC is added, we would have to notify lookupVC to enable its button
//keep it for now, if we add more VCs, then come up with a better solution
protocol LocationObserver {
    func locationDetermined(location: CLLocationCoordinate2D)
}
