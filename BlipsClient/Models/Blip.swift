//
//  Blip.swift
//  BlipsClient
//
//  Created by Cyrus Sadeghi on 2017-11-15.
//  Copyright © 2017 Cyrus Sadeghi. All rights reserved.
//

import Foundation
import MapKit

class Blip: NSObject, MKAnnotation {
    var title: String?
    var coordinate: CLLocationCoordinate2D
    var attractionType: String
    var rating: Float
    var price: Int
    
    init?(json: [String: Any]) {
        guard let name = json["name"] as? String,
        let latitude = json["latitude"] as? Double,
        let longitude = json["longitude"] as? Double,
        let attractionType = json["type"] as? String,
        let rating = json["rating"] as? Float,
        let price = json["price"] as? Int
        else {
            return nil
        }

        self.title = name
        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.attractionType = attractionType
        self.rating = rating
        self.price = price
    }
    
    var subtitle: String? {
        return attractionType
    }
}
