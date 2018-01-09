//
//  ViewController.swift
//  BlipsClient
//
//  Created by Cyrus Sadeghi on 2017-10-26.
//  Copyright © 2017 Cyrus Sadeghi. All rights reserved.
//

import Foundation
import UIKit
import MapKit

// SEPARATE CLASSES SOON

class ViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    
    let locManager = Location()
    
    let regionRadius: CLLocationDistance = 250
    let lookupModel = LookupModel()
    
    var blips = [Blip]()
    
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

    //abstract this and same function in LookupModel
    func serverPostCallback(data: Data) {
        do {
            let responseContents = try ServerInterface.readJSON(data: data)
            
            populateMap(serverDict: responseContents as? Dictionary<String, Dictionary<String, Any>> ?? [:])
        } catch ServerInterfaceError.JSONParseFailed(description: let error) {
            print(error)
        } catch {
            print("Other error")
        }
    }
    
    func populateMap(serverDict: Dictionary<String, Dictionary<String, Any>>) {
        var totalLatitude: Double = 0.0
        var totalLongitude: Double = 0.0
        
        blips.removeAll()
        
        for (_, value) in serverDict {
            // Change these force casts, crash waiting to happen
            let dictEntry = (value as NSDictionary).mutableCopy() as! NSMutableDictionary
            
            let blipEntry = dictEntry as? [String: Any] ?? [:]
            if let blip = Blip(json: blipEntry) {
                totalLatitude += blip.getLatitude()
                totalLongitude += blip.getLongitude()
                
                blips.append(blip)
            }
            else {
                print("Failed to unwrap blip!")
                print(value)
                abort()
            }
        }
        
        let averageLatitude = totalLatitude / Double(serverDict.count)
        let averageLongitude = totalLongitude / Double(serverDict.count)
        let averageCoordinate = CLLocationCoordinate2D(latitude: averageLatitude, longitude: averageLongitude)
        
        centerMapOnBlipCity(location: averageCoordinate)
        
        for blip in blips {
            placePinForBlip(blip: blip)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lookupModel.syncWithServer()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: Navigation
    @IBAction func unwindToBlipMap(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? LookupViewController, let customLookup = sourceViewController.customLookup {
            let customRequest = BlipRequest(inLookup: customLookup, locManager: locManager)
            
            do {
                //abstract up serverPostCallback from here and LookupModel
                try ServerInterface.postServer(jsonRequest: (customRequest?.JSONify())!, callback: { (data) in self.serverPostCallback(data: data) })
            } catch ServerInterfaceError.badJSONRequest(description: let error) {
                print(error)
            } catch {
                print("Other error")
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationNC = segue.destination as? UINavigationController {
            if let lookupVC = destinationNC.topViewController as? LookupViewController {
                lookupVC.lookupModel = self.lookupModel
            }
        }
    }
}
