//
//  MapModel.swift
//  BlipsClient
//
//  Created by Cyrus Sadeghi on 2018-02-02.
//  Copyright © 2018 Cyrus Sadeghi. All rights reserved.
//

import Foundation
import MapKit

class MapModel {
    private var userLatitude: Double = 0.0
    private var userLongitude: Double = 0.0
    
    private let regionRadius: CLLocationDistance = 250
    
    private var blips = [Blip]()
    private var lastAnnotations = [MKAnnotation]()
    
    /*     
     move to MapVC
     func centerMapOnBlipCity(location: CLLocationCoordinate2D) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location, regionRadius, regionRadius)
        
        mapView.setRegion(coordinateRegion, animated: true)
     }
     
     func placePinForBlip(blip: Blip) {
         let annotation = MKPointAnnotation()
         let coordinate = CLLocationCoordinate2D(latitude: blip.getLatitude(), longitude: blip.getLongitude())
     
         annotation.coordinate = coordinate
         annotation.title = blip.getName()
         mapView.addAnnotation(annotation)
     }
     
     // split this between map model and vc
     
     func populateMap(serverDict: Dictionary<String, Dictionary<String, Any>>) {
         blips.removeAll()
         lastAnnotations.removeAll()
     
         for (_, value) in serverDict {
             let dictEntry = (value as NSDictionary).mutableCopy() as! NSMutableDictionary
             let blipEntry = dictEntry as? [String: Any] ?? [:]
     
             if let blip = Blip(json: blipEntry) {
                blips.append(blip)
             }
             else {
                 print("Failed to unwrap blip!")
                 print(value)
                 abort()
             }
         }
     
         let userLocation = CLLocationCoordinate2D(latitude: userLatitude, longitude: userLongitude)
     
         centerMapOnBlipCity(location: userLocation)
     
         for blip in blips {
            placePinForBlip(blip: blip)
         }
     }
     
     // stays in mapmodel
     
     func blipRequestCallback(request: [String: Any], latitude: Double, longitude: Double) {
         self.userLatitude = latitude
         self.userLongitude = longitude
     
         do {
            //abstract up serverPostCallback from here and LookupModel
            try ServerInterface.postServer(jsonRequest: request, callback: { (data) in self.serverPostCallback(data: data) })
         } catch ServerInterfaceError.badJSONRequest(description: let error) {
            print(error)
         } catch {
            print("Other error")
         }
     }
     */
}
