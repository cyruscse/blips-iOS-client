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

// potential TODO:
// use GMSPlacesClient to ascertain openNow status

class Blip: NSObject, MKAnnotation {
    var title: String?
    var coordinate: CLLocationCoordinate2D
    var attractionType: String
    var rating: Double
    var price: Int
    var placeID: String
    var photo: UIImage
    
    init?(json: [String: Any]) {
        guard let name = json["name"] as? String,
        let latitude = json["latitude"] as? Double,
        let longitude = json["longitude"] as? Double,
        let attractionType = json["type"] as? String,
        let rating = json["rating"] as? Double,
        let price = json["price"] as? Int,
        let placeID = json["placeID"] as? String
        else {
            return nil
        }

        self.title = name
        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.attractionType = attractionType
        self.rating = rating
        self.price = price
        self.placeID = placeID
        self.photo = UIImage()
    }
    
    func requestPhotoMetadata() {
        GMSPlacesClient.shared().lookUpPhotos(forPlaceID: placeID) { (photos, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            } else {
                if let firstPhoto = photos?.results.first {
                    self.loadImageForMetadata(photoMetadata: firstPhoto)
                }
            }
        }
    }
    
    func loadImageForMetadata(photoMetadata: GMSPlacePhotoMetadata) {
        GMSPlacesClient.shared().loadPlacePhoto(photoMetadata) { (photo, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            } else {
                self.photo = photo ?? self.photo
            }
        }
    }
    
    var subtitle: String? {
        return attractionType
    }
}
