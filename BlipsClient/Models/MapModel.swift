//
//  MapModel.swift
//  BlipsClient
//
//  Created by Cyrus Sadeghi on 2018-02-02.
//  Copyright © 2018 Cyrus Sadeghi. All rights reserved.
//

import Foundation
import MapKit

class MapModel: UserAccountObserver {
    private let regionRadius: CLLocationDistance = 250
    
    private var blips = [Blip]()
    private var currentAnnotations = [MKAnnotation]()
    private var currentLocation: CLLocationCoordinate2D?
    private var lastAnnotations = [MKAnnotation]()
    private var mapModelObservers = [MapModelObserver]()
    
    func userLoggedIn(account: User) {
        // auto lookup here (choose user's top attractions and current location)
    }
    
    func userLoggedOut() {
        currentAnnotations = []
    }
    
    func addObserver(observer: MapModelObserver) {
        mapModelObservers.append(observer)
    }
    
    func notifyAnnotationsUpdated() {
        for observer in mapModelObservers {
            observer.annotationsUpdated(annotations: currentAnnotations)
        }
    }
    
    func notifyLocationUpdated() {
        for observer in mapModelObservers {
            observer.locationUpdated(location: currentLocation!, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        }
    }
    
    func parseBlips(serverDict: Dictionary<String, Dictionary<String, Any>>) {
        blips.removeAll()
        lastAnnotations.removeAll()
        
        for (_, value) in serverDict {
            let dictEntry = (value as NSDictionary).mutableCopy() as! NSMutableDictionary
            let blipEntry = dictEntry as? [String: Any] ?? [:]
            
            if let blip = Blip(json: blipEntry) {
                blips.append(blip)
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2D(latitude: blip.getLatitude(), longitude: blip.getLongitude())
                annotation.title = blip.getName()
                currentAnnotations.append(annotation)
            }
            else {
                print("Failed to unwrap blip!")
                print(value)
            }
        }
        
        notifyAnnotationsUpdated()
    }
    
    func blipsReplyCallback(data: Data) {
        do {
            let responseContents = try ServerInterface.readJSON(data: data)
            
            parseBlips(serverDict: responseContents as? Dictionary<String, Dictionary<String, Any>> ?? [:])
        } catch ServerInterfaceError.JSONParseFailed(description: let error) {
            print(error)
        } catch {
            print("Other error")
        }
    }
    
    func requestBlips(lookupVC: LookupViewController, accountID: Int, latitude: Double, longitude: Double) {
        let customLookup = CustomLookup(attribute: lookupVC.getSelectedAttractions(), openNow: lookupVC.getOpenNowValue(), radius: lookupVC.getRadiusValue())
        let blipRequest = BlipRequest(inLookup: customLookup!, accountID: accountID, latitude: latitude, longitude: longitude)
        let request = blipRequest.JSONify()
        
        ServerInterface.makeRequest(request: request, callback: blipsReplyCallback)
        
        currentLocation = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        notifyLocationUpdated()
    }
    
    /*
     func placePinForBlip(blip: Blip) {
         let annotation = MKPointAnnotation()
         let coordinate = CLLocationCoordinate2D(latitude: blip.getLatitude(), longitude: blip.getLongitude())
     
         annotation.coordinate = coordinate
         annotation.title = blip.getName()
         mapView.addAnnotation(annotation)
     }
     
     // split this between map model and vc
     
     */
}
