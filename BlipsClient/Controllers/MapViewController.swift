//
//  MapViewController.swift
//  BlipsClient
//
//  Created by Cyrus Sadeghi on 2018-02-03.
//  Copyright © 2018 Cyrus Sadeghi. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: MKMapView, MapModelObserver, MKMapViewDelegate {
    private var myAnnotations = [MKAnnotation]()
    private var currentLocation: MKCoordinateRegion!
    private var mainVC: ViewController!
    
    func setMainVC(vc: ViewController) {
        self.mainVC = vc
    }
    
    func annotationsUpdated(annotations: [MKAnnotation]) {
        self.removeAnnotations(myAnnotations)
        self.myAnnotations = annotations
        self.addAnnotations(myAnnotations)
    }
    
    func locationUpdated(location: CLLocationCoordinate2D, latitudinalMeters: CLLocationDistance, longitudinalMeters: CLLocationDistance) {
        currentLocation = MKCoordinateRegionMakeWithDistance(location, latitudinalMeters, longitudinalMeters)
        self.setRegion(currentLocation, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        mainVC.segueToBlipDetail(sender: control, annotation: (view as? BlipMarkerView)!)
    }
}
