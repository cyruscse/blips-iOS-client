//
//  Location.swift
//  BlipsClient
//
//  Created by Cyrus Sadeghi on 2018-01-09.
//  Copyright © 2018 Cyrus Sadeghi. All rights reserved.
//

// Location Manager for BlipsClient. Interfaces with the iOS location APIs to get the client's location.
// Maintains a list of LocationObservers, once the client's location is determined, the observers are notified
// with the coordinates of the device.

import Foundation
import CoreLocation

class Location: NSObject, CLLocationManagerDelegate {
    let manager = CLLocationManager()
    private var locationCallback: (CLLocationCoordinate2D) -> ()
    private var locationObservers = [LocationObserver]()
    
    var location: CLLocationCoordinate2D!
    
    override init() {
        self.locationCallback = {_ in }
        
        super.init()
        enableLocationServices()
    }
    
    // Request Location Services from the user. Presents a system pop-up asking
    // if the user wants to always give location access, or only if the app is open.
    func enableLocationServices() {
        switch CLLocationManager.authorizationStatus() {
            case .notDetermined:
                manager.requestWhenInUseAuthorization()
                break
            
            case .restricted, .denied:
                print("Fallback to custom search...")
                break
            
            case .authorizedWhenInUse, .authorizedAlways:
                break
        }
        
        if (CLLocationManager.locationServicesEnabled()) {
            manager.delegate = self
            manager.desiredAccuracy = kCLLocationAccuracyBest
        }
    }
    
    // Automatically called by the Location API if the user's location changes
    internal func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = (manager.location?.coordinate)!
        
        locationCallback(locValue)
    }
    
    // Automatically called by the Location API if the location can't be determined
    internal func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error")
    }
    
    // Request the device's location, call the passed callback function on completion
    func getLocation(callback: @escaping (CLLocationCoordinate2D) -> ()) {
        manager.requestLocation()
        
        self.locationCallback = callback
    }
    
    // Notify our observers if the device's location changes
    func updateObservers() {
        for observer in locationObservers {
            observer.locationDetermined(location: location)
        }
    }
    
    // Callback for getLocation, saves the device's coordinates then notifies observers
    func getLocationCallback(coordinate: CLLocationCoordinate2D) {
        self.location = coordinate
        
        updateObservers()
    }
    
    func addLocationObserver(observer: LocationObserver) {
        locationObservers.append(observer)
        
        if location != nil {
            observer.locationDetermined(location: location)
        }
    }
    
    func getLatitude() -> Double {
        return self.location.latitude
    }
    
    func getLongitude() -> Double {
        return self.location.longitude
    }
}
