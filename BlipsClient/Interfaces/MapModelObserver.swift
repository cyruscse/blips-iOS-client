//
//  MapModelObserver.swift
//  BlipsClient
//
//  Created by Cyrus Sadeghi on 2018-02-03.
//  Copyright © 2018 Cyrus Sadeghi. All rights reserved.
//

import Foundation
import MapKit

protocol MapModelObserver {
    func annotationsUpdated(annotations: [MKAnnotation])
    func locationUpdated(location: CLLocationCoordinate2D, latitudinalMeters: CLLocationDistance, longitudinalMeters: CLLocationDistance)
}
