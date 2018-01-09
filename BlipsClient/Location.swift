//
//  Location.swift
//  BlipsClient
//
//  Created by Cyrus Sadeghi on 2018-01-09.
//  Copyright © 2018 Cyrus Sadeghi. All rights reserved.
//

import Foundation
import CoreLocation

class Location: NSObject, CLLocationManagerDelegate {
    let manager = CLLocationManager()
    var locationCallback: (CLLocationCoordinate2D) -> ()
    
    override init() {
        self.locationCallback = {_ in }
        
        super.init()
        enableLocationServices()
    }
    
    func enableLocationServices() {
        switch CLLocationManager.authorizationStatus() {
            case .notDetermined:
                manager.requestWhenInUseAuthorization()
                break
            
            case .restricted, .denied:
                print("Fallback to custom search...")
                break
            
            case .authorizedWhenInUse, .authorizedAlways:
                print("Got location features")
                break
        }
        
        if (CLLocationManager.locationServicesEnabled()) {
            manager.delegate = self
            manager.desiredAccuracy = kCLLocationAccuracyBest
        }
    }
    
    internal func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = (manager.location?.coordinate)!
        print("location = \(locValue.latitude) \(locValue.longitude)")
        
        locationCallback(locValue)
    }
    
    internal func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error")
    }
    
    func getLocation(callback: @escaping (CLLocationCoordinate2D) -> ()) {
        manager.requestLocation()
        
        self.locationCallback = callback
    }
}
