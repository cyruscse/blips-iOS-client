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

class Blip: NSObject, MKAnnotation, NSCoding {
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
    var information: String
    
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
        self.information = ""
    }
    
    init(title: String, coordinate: CLLocationCoordinate2D, attractionType: String, rating: Double, price: Int, placeID: String, photos: [UIImage], photoMetadata: [GMSPlacePhotoMetadata], retrievedPhotos: Bool, icon: URL, information: String) {
        self.title = title
        self.coordinate = coordinate
        self.attractionType = attractionType
        self.rating = rating
        self.price = price
        self.placeID = placeID
        self.photos = photos
        self.photoMetadata = photoMetadata
        self.retrievedPhotos = retrievedPhotos
        self.icon = icon
        self.information = information
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
    
    // NSCoding Methods
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(title, forKey: "title")
        aCoder.encode(coordinate.latitude, forKey: "latitude")
        aCoder.encode(coordinate.longitude, forKey: "longitude")
        aCoder.encode(attractionType, forKey: "attractionType")
        aCoder.encode(rating, forKey: "rating")
        aCoder.encode(price, forKey: "price")
        aCoder.encode(placeID, forKey: "placeID")
        aCoder.encode(icon, forKey: "icon")
        aCoder.encode(information, forKey: "information")
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let name = aDecoder.decodeObject(forKey: "title") as! String
        let latitude = aDecoder.decodeDouble(forKey: "latitude")
        let longitude = aDecoder.decodeDouble(forKey: "longitude")
        let type = aDecoder.decodeObject(forKey: "attractionType") as! String
        let blipRating = aDecoder.decodeDouble(forKey: "rating")
        let blipPrice = aDecoder.decodeInteger(forKey: "price")
        let id = aDecoder.decodeObject(forKey: "placeID") as! String
        let iconURL = aDecoder.decodeObject(forKey: "icon") as! URL
        let info = aDecoder.decodeObject(forKey: "information") as! String
        
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        self.init(title: name, coordinate: location, attractionType: type, rating: blipRating, price: blipPrice, placeID: id, photos: [UIImage](), photoMetadata: [GMSPlacePhotoMetadata](), retrievedPhotos: false, icon: iconURL, information: info)
    }
    
    // NSCoding Methods end
}
