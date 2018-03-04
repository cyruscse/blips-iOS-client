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

enum UpdateType {
    case LookupRefresh
    case ServerLookup
    case SavedBlip
    case MapClear
    case MapRestore
}

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
        
        autoQueryBlips()
    }
    
    // LocationObserver Methods end
    
    // UserAccountObserver Methods
    
    func userLoggedIn(account: User) {
        self.account = account
        
        if account.getAttractionHistoryCount() != 0 && currentLocation != nil {
            autoQueryBlips()
        }
    }
    
    // On a user logout, clear the annotations on the map
    func userLoggedOut() {
        currentAnnotations = []
        lastAnnotations = []
        self.account = nil
        notifyAnnotationsUpdated(updateType: UpdateType.MapClear)
    }
    
    func guestReplaced(guestQueried: Bool) {}
    
    // UserAccountObserver Methods end

    func focusMapOnBlip(blip: Blip) {
        for observer in mapModelObservers {
            observer.focusOnBlip(blip: blip)
        }
    }

    func addObserver(observer: MapModelObserver) {
        mapModelObservers.append(observer)
    }
    
    // Notify MapVC when its annotations should change
    func notifyAnnotationsUpdated(updateType: UpdateType) {
        if currentAnnotations.count != 0 {
            haveAnnotations = true
        } else {
            haveAnnotations = false
        }
        
        DispatchQueue.main.async {
            for observer in self.mapModelObservers {
                observer.annotationsUpdated(annotations: self.currentAnnotations, updateType: updateType)
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
        notifyAnnotationsUpdated(updateType: UpdateType.MapClear)
    }
    
    // As explained above, restore the saved annotations to the MapVC
    func restoreMapVC() {
        currentAnnotations = lastAnnotations
        notifyAnnotationsUpdated(updateType: UpdateType.MapRestore)
    }
    
    // Server query request methods
    
    // Given a dictionary of blips (saved as Strings), convert them to Blip objects
    // and create annotations for each. Add the annotations to our list then notify MapVC when we're done.
    func parseBlips(serverDict: [Dictionary<String, Any>]) {
        currentAnnotations.removeAll()
        lastAnnotations.removeAll()
        
        for entry in serverDict {
            let dictEntry = (entry as NSDictionary).mutableCopy() as! NSMutableDictionary
            let blipEntry = dictEntry as? [String: Any] ?? [:]
            
            if let blip = Blip(json: blipEntry) {
                currentAnnotations.append(blip)
                blip.requestPhotoMetadata()
            } else {
                let alert = UIAlertController(title: "Blip Display Failed", message: "The server didn't send blips in the correct format.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                
                var rootVC = UIApplication.shared.keyWindow?.rootViewController
                
                if let navigationVC = rootVC as? UINavigationController {
                    rootVC = navigationVC.viewControllers.first
                }
                
                rootVC?.present(alert, animated: true, completion: nil)
                
                return
            }
        }
        
        notifyAnnotationsUpdated(updateType: UpdateType.ServerLookup)
    }
    
    func placeBlips(blips: [Blip]) {
        currentAnnotations.removeAll()
        lastAnnotations.removeAll()
        
        currentAnnotations.append(contentsOf: blips)
        notifyAnnotationsUpdated(updateType: UpdateType.SavedBlip)
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
                let alert = UIAlertController(title: "Query Failed", message: "The server was unable to handle your request.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                
                var rootVC = UIApplication.shared.keyWindow?.rootViewController
                
                if let navigationVC = rootVC as? UINavigationController {
                    rootVC = navigationVC.viewControllers.first
                }
                
                rootVC?.present(alert, animated: true, completion: nil)
            }
        } catch ServerInterfaceError.JSONParseFailed(description: let error) {
            print(error)
        } catch {
            print("Blip Query failed")
        }
    }
    
    func autoQueryBlips() {
        if account.autoQueryOptions.autoQueryEnabled == false {
            return
        }
        
        if account.autoQueryOptions.autoQueryTypeGrabLength == 0 {
            // This returns if the account hasn't queried before.
            // I need to change this to query with a list of "top" attractions from the server
            return
        }
        
        // Center on user location, blips haven't been retrieved yet
        notifyLocationUpdated()
        
        // Initializes MapAccessoryViews on load
        notifyAnnotationsUpdated(updateType: UpdateType.ServerLookup)
        
        let topTypes = Array(account.orderedAttractionHistory()[0...(account.autoQueryOptions.autoQueryTypeGrabLength - 1)])
        let topTypesStrings = topTypes.map { $0.attraction }
        
        requestBlips(attributes: topTypesStrings, openNow: account.autoQueryOptions.autoQueryOpenNow, radius: 10000, priceRange: account.autoQueryOptions.autoQueryPriceRange, minimumRating: account.autoQueryOptions.autoQueryRating, latitude: currentLocation!.latitude, longitude: currentLocation!.longitude)
    }
    
    func manualRequestBlips(lookupVC: LookupTableViewController, latitude: Double, longitude: Double) {
        requestBlips(attributes: lookupVC.selectedAttractionTypes, openNow: lookupVC.openNow, radius: lookupVC.getRadiusValue(), priceRange: lookupVC.priceRange, minimumRating: lookupVC.getMinimumRating(), latitude: latitude, longitude: longitude)
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
