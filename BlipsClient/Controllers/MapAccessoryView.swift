//
//  MapAccessoryView.swift
//  BlipsClient
//
//  Created by Cyrus Sadeghi on 2018-02-16.
//  Copyright © 2018 Cyrus Sadeghi. All rights reserved.
//

import UIKit
import MapKit

class MapAccessoryView: UIView, MapModelObserver {
    func annotationsUpdated(annotations: [MKAnnotation]) {
        DispatchQueue.main.async {            
            if annotations.count == 0 {
                self.isHidden = true
                self.isUserInteractionEnabled = false
            } else {
                self.isHidden = false
                self.isUserInteractionEnabled = true
            }
        }
    }
    
    func locationUpdated(location: CLLocationCoordinate2D, latitudinalMeters: CLLocationDistance, longitudinalMeters: CLLocationDistance) {}
    
    func focusOnBlip(blip: Blip) {}
}
