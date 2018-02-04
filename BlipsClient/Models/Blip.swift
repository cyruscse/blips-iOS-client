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
    
    init?(json: [String: Any]) {
        guard let name = json["name"] as? String,
        let latitude = json["latitude"] as? Double,
        let longitude = json["longitude"] as? Double,
        let attractionType = json["type"] as? String
        //let rating = json["rating"] as? Float
        else {
            return nil
        }

        self.title = name
        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.attractionType = attractionType
        //self.rating = rating
    }
    
    func getLatitude() -> Double {
        return self.coordinate.latitude
    }
    
    func getLongitude() -> Double {
        return self.coordinate.longitude
    }
    
    var subtitle: String? {
        return attractionType
    }
}
