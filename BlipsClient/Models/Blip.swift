//
//  Blip.swift
//  BlipsClient
//
//  Created by Cyrus Sadeghi on 2017-11-15.
//  Copyright © 2017 Cyrus Sadeghi. All rights reserved.
//

import Foundation

struct Blip {
    let name: String
    let coordinates: (latitude: Double, longitude: Double)
   // let rating: Float
}

extension Blip {
    init?(json: [String: Any]) {
        guard let name = json["name"] as? String,
        let latitude = json["latitude"] as? Double,
        let longitude = json["longitude"] as? Double
        //let rating = json["rating"] as? Float
        else {
            return nil
        }

        self.name = name
        self.coordinates = (latitude, longitude)
        //self.rating = rating
    }
    
    func getName() -> String {
        return self.name
    }
    
    func getLatitude() -> Double {
        return self.coordinates.latitude
    }
    
    func getLongitude() -> Double {
        return self.coordinates.longitude
    }
}
