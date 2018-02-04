//
//  BlipMarkerView.swift
//  BlipsClient
//
//  Created by Cyrus Sadeghi on 2018-02-04.
//  Copyright © 2018 Cyrus Sadeghi. All rights reserved.
//

import Foundation
import MapKit

class BlipMarkerView: MKMarkerAnnotationView {
    override var annotation: MKAnnotation? {
        willSet {
            guard let _ = newValue as? Blip else { return }
            canShowCallout = true
            calloutOffset = CGPoint(x: -5, y: 5)
            rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
    }
}
