//
//  MapViewController.swift
//  BlipsClient
//
//  Created by Cyrus Sadeghi on 2018-02-03.
//  Copyright © 2018 Cyrus Sadeghi. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: MKMapView, MapModelObserver {
    private var myAnnotations = [MKAnnotation]()
    private var currentLocation: MKCoordinateRegion!
    
    func topCenterCoordinate() -> CLLocationCoordinate2D {
        return self.convert(CGPoint(x: self.frame.size.width / 2.0, y: 0), toCoordinateFrom: self)
    }
    
    func currentRadius() -> Double {
        let centerLocation = CLLocation(latitude: self.centerCoordinate.latitude, longitude: self.centerCoordinate.longitude)
        let topCenterCoordinate = self.topCenterCoordinate()
        let topCenterLocation = CLLocation(latitude: topCenterCoordinate.latitude, longitude: topCenterCoordinate.longitude)
        
        return centerLocation.distance(from: topCenterLocation)
    }

    // MapModelObserver methods
    
    func annotationsUpdated(annotations: [MKAnnotation], updateType: UpdateType) {
        self.removeAnnotations(myAnnotations)
        self.myAnnotations = annotations
        self.addAnnotations(myAnnotations)
    }
    
    func locationUpdated(location: CLLocationCoordinate2D, latitudinalMeters: CLLocationDistance, longitudinalMeters: CLLocationDistance) {
        currentLocation = MKCoordinateRegionMakeWithDistance(location, latitudinalMeters, longitudinalMeters)
        self.setRegion(currentLocation, animated: true)
    }
    
    func focusOnBlip(blip: Blip) {
        self.selectAnnotation(blip, animated: true)
    }
}
