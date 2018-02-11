//
//  Blip.swift
//  BlipsClient
//
//  Created by Cyrus Sadeghi on 2017-11-15.
//  Copyright © 2017 Cyrus Sadeghi. All rights reserved.
//

import Foundation
import MapKit
import GooglePlaces

// TODO:
// use GMSPlacesClient to ascertain openNow status

class Blip: NSObject, MKAnnotation {
    // Server sends the suffix for the icon (i.e. for a hotel, icon will contain "lodging-71.png")
    static let iconURLPrefix: String = "https://maps.gstatic.com/mapfiles/place_api/icons/"
    
    var title: String?
    var coordinate: CLLocationCoordinate2D
    var attractionType: String
    var rating: Double
    var price: Int
    var placeID: String
    var photos: [UIImage] = []
    var photoMetadata: [GMSPlacePhotoMetadata] = []
    var retrievedPhotos: Bool = false
    var icon: URL
    
    var observers: [BlipObserver] = []
    
    init?(json: [String: Any]) {
        guard let name = json["name"] as? String,
        let latitude = json["latitude"] as? Double,
        let longitude = json["longitude"] as? Double,
        let attractionType = json["type"] as? String,
        let rating = json["rating"] as? Double,
        let price = json["price"] as? Int,
        let placeID = json["placeID"] as? String,
        let iconSuffix = json["icon"] as? String
        else {
            return nil
        }

        self.title = name
        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.attractionType = attractionType
        self.rating = rating
        self.price = price
        self.placeID = placeID
        // Force unwrapping this is fine, String contents are set by the time this happens
        self.icon = URL(string: (Blip.iconURLPrefix + iconSuffix))!
    }
    
    func addObserver(observer: BlipObserver) {
        self.observers.append(observer)
    }
    
    func notifyPhotosReady() {
        for observer in observers {
            observer.photosReady()
        }
    }

    func requestPhotoMetadata() {
        GMSPlacesClient.shared().lookUpPhotos(forPlaceID: placeID) { (netPhotos, error) in
            if let _ = error {
                print("Failed to lookup metadata for blip \(String(describing: error?.localizedDescription))")
            } else {
                if let results = netPhotos?.results {
                    self.photoMetadata.append(contentsOf: results)
                }
            }
        }
    }
    
    func loadImagesForMetadata() {
        if retrievedPhotos == true {
            notifyPhotosReady()
        }
        
        retrievedPhotos = true
        
        for metadata in photoMetadata {
            GMSPlacesClient.shared().loadPlacePhoto(metadata) { (photo, error) in
                if let _ = error {
                    print("Failed to lookup photo for blip \(String(describing: error?.localizedDescription))")
                } else {
                    self.photos.append(photo!)
                    
                    if self.photoMetadata.count == self.photos.count {
                        self.notifyPhotosReady()
                    }
                }
            }
        }
    }
    
    func mapItem() -> MKMapItem {
        let placeMark = MKPlacemark(coordinate: self.coordinate)
        let mapItem = MKMapItem(placemark: placeMark)
        mapItem.name = self.title
        
        return mapItem
    }
    
    var subtitle: String? {
        return attractionType
    }
}
