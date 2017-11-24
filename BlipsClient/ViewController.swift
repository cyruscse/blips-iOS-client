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
    @IBAction func cityIDIn(_ sender: Any) {
        let senderAsField = sender as? UITextField
        
        print(senderAsField?.text ?? "rip")
    }
    
    @IBOutlet weak var mapView: MKMapView!
    
    //remove this method
    @IBAction func newBlip(_ sender: Any) {
        let senderAsButton = sender as? UIButton
        
        senderAsButton?.isEnabled = false
        
        //let jsonRequest = ["cityID": String(arc4random_uniform(400)), "type": "lodging"]
        
        blips.removeAll()
    
        /*do {
            let response = try ServerInterface.postServer(jsonRequest: jsonRequest)
            let dictionary = try ServerInterface.readJSON(data: response)
            
            print(dictionary)
        } catch ServerInterfaceError.badJSONRequest(description: let error) {
            print(error)
        } catch ServerInterfaceError.badResponseFromServer(description: let error) {
            print(error)
        } catch {
            print("Other error")
        }
        */
        senderAsButton?.isEnabled = true
    }
    
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
    
    func populateMap(serverDict: Dictionary<String, Any>) {
        var totalLatitude: Double = 0.0
        var totalLongitude: Double = 0.0
        var skippedBlipCount: Int = 0
        
        for (key, value) in serverDict {
            // Skip non-blip JSON
            if Int(key) == nil {
                skippedBlipCount += 1
                print(value)
                continue
            }
            
            // Change these force casts, crash waiting to happen
            let dictEntry = (value as! NSArray).mutableCopy() as! NSMutableArray
            let blipEntry = dictEntry[0] as? [String: Any] ?? [:]
            if let blip = Blip(json: blipEntry) {
                print(value)
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
        
        // Subtract 1 from blip count to account for non-blip in JSON
        let averageLatitude = totalLatitude / Double(serverDict.count - skippedBlipCount)
        let averageLongitude = totalLongitude / Double(serverDict.count - skippedBlipCount)
        let averageCoordinate = CLLocationCoordinate2D(latitude: averageLatitude, longitude: averageLongitude)
        
        print(averageLatitude)
        print(averageLongitude)
        print(averageCoordinate)
        
        centerMapOnBlipCity(location: averageCoordinate)
        
        for blip in blips {
            placePinForBlip(blip: blip)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lookupModel.syncWithServer()
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let lookupVC = segue.destination as? LookupViewController {
            lookupVC.lookupModel = self.lookupModel
        }
    }
}

