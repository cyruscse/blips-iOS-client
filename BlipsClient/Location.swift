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
    private var locationCallback: (CLLocationCoordinate2D) -> ()
    private var latitude: Double = 0.0
    private var longitude: Double = 0.0
    private var locationObservers = [LocationObserver]()
    
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
        
        locationCallback(locValue)
    }
    
    internal func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error")
    }
    
    func getLocation(callback: @escaping (CLLocationCoordinate2D) -> ()) {
        manager.requestLocation()
        
        self.locationCallback = callback
    }
    
    func getLocationCallback(coordinate: CLLocationCoordinate2D) {
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
        
        for observer in locationObservers {
            observer.locationDetermined()
        }
    }
    
    func addLocationObserver(observer: LocationObserver) {
        locationObservers.append(observer)
    }
    
    func getLatitude() -> Double {
        return self.latitude
    }
    
    func getLongitude() -> Double {
        return self.longitude
    }
}
