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
        
        let jsonRequest = ["cityID": String(arc4random_uniform(400)), "type": "lodging"]
        
        blips.removeAll()
        
        postBlipsServer(jsonRequest: jsonRequest)
        
        senderAsButton?.isEnabled = true
    }
    
    let session = URLSession.shared
    let url:URL = URL(string: "http://www.blipsserver-env.us-east-2.elasticbeanstalk.com")!
    let regionRadius: CLLocationDistance = 250
    
    var blips = [Blip]()
    var pickerData: [String] = [String]()
    
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
    
    func readJSON(data: Data) -> Dictionary<String, Any> {
        do {
            let json = try JSONSerialization.jsonObject(with: data)
            
            if let dictionary = json as? [String: Any] {
                return dictionary
            }
        } catch {
            print (error)
        }
        
        //temporarily return empty dictionary, change this method to throw an error if json parse fails (i.e, remove do catch block)
        let myDict: [String: Any] = [:]
        
        return myDict
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
 
    func postBlipsServer(jsonRequest: [String: String]) {
        // pull this up into a JSON request model class, this code is duplicated in LookupModel
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: jsonRequest, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
            
            return
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = session.dataTask(with: request as URLRequest, completionHandler : { data, response, error in
            guard error == nil else {
                return
            }
            
            guard let data = data else {
                return
            }
            
            //change this
            let serverResponse = self.readJSON(data: data)
            
            if (serverResponse.count != 0) {
                self.populateMap(serverDict: serverResponse)
            }
        })
        
        task.resume()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let testLookup = LookupModel()
        
        testLookup.syncWithServer()
        
        pickerData = ["Item 1", "Item 2", "Item 3"]
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

