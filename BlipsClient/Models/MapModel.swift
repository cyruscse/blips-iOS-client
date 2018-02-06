//
//  MapModel.swift
//  BlipsClient
//
//  Created by Cyrus Sadeghi on 2018-02-02.
//  Copyright © 2018 Cyrus Sadeghi. All rights reserved.
//

// MapModel is the model for MapVC. It maintains the list of annotations currently on the map,
// the location the map is centered on, etc.

import Foundation
import MapKit

class MapModel: UserAccountObserver {
    private let regionRadius: CLLocationDistance = 250
    
    private var currentAnnotations = [Blip]()
    private var currentLocation: CLLocationCoordinate2D?
    private var lastAnnotations = [Blip]()
    private var mapModelObservers = [MapModelObserver]()
    
    // Not implemented yet, but the plan is to automatically query the server with
    // the user's location and top attractions on user login
    func userLoggedIn(account: User) {
        // auto lookup here (choose user's top attractions and current location)
    }
    
    // On a user logout, clear the annotations on the map
    func userLoggedOut() {
        currentAnnotations = []
        lastAnnotations = []
        notifyAnnotationsUpdated()
    }
    
    func guestReplaced() {}
    
    func addObserver(observer: MapModelObserver) {
        mapModelObservers.append(observer)
    }
    
    // Notify MapVC when its annotations should change
    func notifyAnnotationsUpdated() {
        for observer in mapModelObservers {
            observer.annotationsUpdated(annotations: currentAnnotations)
        }
    }
    
    // Notify MapVC to change the location it is focused on
    func notifyLocationUpdated() {
        for observer in mapModelObservers {
            observer.locationUpdated(location: currentLocation!, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        }
    }
    
    // Clear annotations from the MapVC.
    // We save the list of annotations when we invoke LookupVC. If a lookup occurs then
    // we update the annnotations on the map from that lookup. If the user cancels that lookup,
    // we restore the annotations that used to be on the map.
    func clearMapVC(retainAnnotations: Bool) {
        if retainAnnotations == true {
            lastAnnotations = currentAnnotations
        }
        else {
            lastAnnotations = []
        }
        
        currentAnnotations = []
        notifyAnnotationsUpdated()
    }
    
    // As explained above, restore the saved annotations to the MapVC
    func restoreMapVC() {
        currentAnnotations = lastAnnotations
        notifyAnnotationsUpdated()
    }
    
    // Server query request methods
    
    // Given a dictionary of blips (saved as Strings), convert them to Blip objects
    // and create annotations for each. Add the annotations to our list then notify MapVC when we're done.
    func parseBlips(serverDict: Dictionary<String, Dictionary<String, Any>>) {
        currentAnnotations.removeAll()
        lastAnnotations.removeAll()
        
        for (_, value) in serverDict {
            let dictEntry = (value as NSDictionary).mutableCopy() as! NSMutableDictionary
            let blipEntry = dictEntry as? [String: Any] ?? [:]
            
            if let blip = Blip(json: blipEntry) {
                currentAnnotations.append(blip)
            }
            else {
                print("Failed to unwrap blip!")
                print(value)
            }
        }
        
        notifyAnnotationsUpdated()
    }
    
    // Callback function for server query.
    // Parse the returned JSON file and pass it to parseBlips
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
    
    // Create a JSON request containing the user's location, ID, attraction types, and radius.
    // Send the request to the server and call our callback function on reply.
    // Center the map on the user's location.
    func requestBlips(lookupVC: LookupViewController, accountID: Int, latitude: Double, longitude: Double) {
        let customLookup = CustomLookup(attribute: lookupVC.getSelectedAttractions(), openNow: lookupVC.getOpenNowValue(), radius: lookupVC.getRadiusValue(), priceRange: lookupVC.getPriceRange(), minimumRating: lookupVC.getMinimumRating())
        let blipRequest = BlipRequest(inLookup: customLookup!, accountID: accountID, latitude: latitude, longitude: longitude)
        let request = blipRequest.JSONify()

        ServerInterface.makeRequest(request: request, callback: blipsReplyCallback)
        
        currentLocation = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        notifyLocationUpdated()
    }
}
