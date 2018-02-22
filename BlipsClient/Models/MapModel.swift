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

class MapModel: NSObject, UserAccountObserver, LocationObserver, MKMapViewDelegate {
    private let regionRadius: CLLocationDistance = 250
    
    private var currentAnnotations = [Blip]()
    private var currentLocation: CLLocationCoordinate2D?
    private var lastAnnotations = [Blip]()
    private var mapModelObservers = [MapModelObserver]()
    private var account: User!
    private var haveAnnotations = false
    private var lastQueryLocation: CLLocationCoordinate2D!
    
    var mainVC: ViewController!
    
    // LocationObserver Methods
    
    func locationDetermined(location: CLLocationCoordinate2D) {
        if (location.latitude == self.currentLocation?.latitude) && (location.longitude == self.currentLocation?.longitude) {
            return
        }
        
        self.currentLocation = location
        
        // Center on user location, blips haven't been retrieved yet
        notifyLocationUpdated()
        
        // Initializes MapAccessoryViews on load
        notifyAnnotationsUpdated()
        
        let topTypes = Array(account.orderedAttractionHistory()[0...account.autoQueryTypeGrabLength])
        let topTypesStrings = topTypes.map { $0.attraction }
        
        requestBlips(attributes: topTypesStrings, openNow: true, radius: 10000, priceRange: 3, minimumRating: 0.0, latitude: location.latitude, longitude: location.longitude)
    }
    
    // UserAccountObserver Methods
    
    // Not implemented yet, but the plan is to automatically query the server with
    // the user's location and top attractions on user login
    func userLoggedIn(account: User) {
        // auto lookup here (choose user's top attractions and current location)
        self.account = account
    }
    
    // On a user logout, clear the annotations on the map
    func userLoggedOut() {
        currentAnnotations = []
        lastAnnotations = []
        self.account = nil
        notifyAnnotationsUpdated()
    }
    
    func guestReplaced() {}
    
    func focusMapOnBlip(blip: Blip) {
        for observer in mapModelObservers {
            observer.focusOnBlip(blip: blip)
        }
    }

    func addObserver(observer: MapModelObserver) {
        mapModelObservers.append(observer)
    }
    
    // Notify MapVC when its annotations should change
    func notifyAnnotationsUpdated() {
        if currentAnnotations.count != 0 {
            haveAnnotations = true
        } else {
            haveAnnotations = false
        }
        
        DispatchQueue.main.async {
            for observer in self.mapModelObservers {
                observer.annotationsUpdated(annotations: self.currentAnnotations)
            }
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
    func parseBlips(serverDict: [Dictionary<String, Any>]) {
        currentAnnotations.removeAll()
        lastAnnotations.removeAll()
        
        var blipUnwrapFailed: Bool = false
        
        for entry in serverDict {
            let dictEntry = (entry as NSDictionary).mutableCopy() as! NSMutableDictionary
            let blipEntry = dictEntry as? [String: Any] ?? [:]
            
            if let blip = Blip(json: blipEntry) {
                currentAnnotations.append(blip)
                blip.requestPhotoMetadata()
            }
            else {
                if blipUnwrapFailed == false {
                    blipUnwrapFailed = true
                    
                    let alert = AnywhereUIAlertController(title: "Blip Display Failed", message: "The server didn't send blips in the correct format.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in }))
                    alert.show()
                }
            }
        }
        
        notifyAnnotationsUpdated()
    }
    
    // Callback function for server query.
    // Parse the returned JSON file and pass it to parseBlips
    func blipsReplyCallback(data: Data) {
        do {
            let responseContents = try ServerInterface.readJSON(data: data)
            let status = responseContents["status"] as? [String] ?? []
            let blipsArr = responseContents["blips"] as? [Dictionary<String, Any>] ?? []
            
            if (status[0] == "OK") {
                parseBlips(serverDict: blipsArr)
            }
            else {
                let alert = AnywhereUIAlertController(title: "Query Failed", message: status[0], preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in }))
                alert.show()
            }
        } catch ServerInterfaceError.JSONParseFailed(description: let error) {
            print(error)
        } catch {
            print("Other error")
        }
    }
    
    func manualRequestBlips(lookupVC: LookupViewController, latitude: Double, longitude: Double) {
        requestBlips(attributes: lookupVC.getSelectedAttractions(), openNow: lookupVC.getOpenNowValue(), radius: lookupVC.getRadiusValue(), priceRange: lookupVC.getPriceRange(), minimumRating: lookupVC.getMinimumRating(), latitude: latitude, longitude: longitude)
    }
    
    func mapRefreshBlipRequest(location: CLLocationCoordinate2D, radius: Int) {
        let lastLookup = account.lastQuery
        requestBlips(attributes: (lastLookup?.getAttributes())!, openNow: (lastLookup?.getOpenNow())!, radius: radius, priceRange: (lastLookup?.getPriceRange())!, minimumRating: (lastLookup?.getMinimumRating())!, latitude: location.latitude, longitude: location.longitude)
    }
    
    // Create a JSON request containing the user's location, ID, attraction types, and radius.
    // Send the request to the server and call our callback function on reply.
    // Center the map on the user's location.
    func requestBlips(attributes: [String], openNow: Bool, radius: Int, priceRange: Int, minimumRating: Double, latitude: Double, longitude: Double) {
        let customLookup = CustomLookup(attribute: attributes, openNow: openNow, radius: radius, priceRange: priceRange, minimumRating: minimumRating)
        let blipRequest = BlipRequest(inLookup: customLookup!, accountID: account.getID(), latitude: latitude, longitude: longitude)
        let request = blipRequest.JSONify()
        
        account.lastQuery = customLookup
        lastQueryLocation = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        ServerInterface.makeRequest(request: request, callback: blipsReplyCallback)
        
        currentLocation = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        notifyLocationUpdated()
    }
    
    // Navigation
    func distanceBetweenLocations(coordinate1: CLLocationCoordinate2D, coordinate2: CLLocationCoordinate2D) -> CLLocationDistance {
        let from = CLLocation(latitude: coordinate1.latitude, longitude: coordinate1.longitude)
        let to = CLLocation(latitude: coordinate2.latitude, longitude: coordinate2.longitude)
        
        return to.distance(from: from)
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        mainVC.segueToBlipDetail(sender: control, annotation: (view as? BlipMarkerView)!)
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if !haveAnnotations {
            return
        }
        
        if distanceBetweenLocations(coordinate1: lastQueryLocation, coordinate2: mapView.centerCoordinate) > Double(account.lastQuery.getRadius()) {
            mainVC.showRefreshButton()
        } else {
            mainVC.hideRefreshButton()
        }
    }
}
