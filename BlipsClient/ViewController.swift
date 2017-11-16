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

class ViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    let initialLocation = CLLocation(latitude: 21.282778, longitude: -157.829444)
    let regionRadius: CLLocationDistance = 10
    
    let jsonRequest = ["cityID": "7", "type": "lodging"]
    let session = URLSession.shared
    let url:URL = URL(string: "http://www.blipsserver-env.us-east-2.elasticbeanstalk.com")!
    
    var blips = [Blip]()
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius, regionRadius)
        
        mapView.setRegion(coordinateRegion, animated: true)
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
        for (key, value) in serverDict {
            // Skip non-blip JSON
            if Int(key) == nil {
                continue
            }
            
            // Change these force casts, crash waiting to happen
            let dictEntry = (value as! NSArray).mutableCopy() as! NSMutableArray
            let blipEntry = dictEntry[0] as? [String: Any] ?? [:]
            let blip = Blip(json: blipEntry)
            
            blips.append(blip!)
        }
        
        for value in blips {
            print(value.getName())
        }

        //let testLocation = CLLocation(latitude: serverDict[2)
    }
 
    func postBlipsServer() {
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
            
            let serverResponse = self.readJSON(data: data)
            self.populateMap(serverDict: serverResponse)
        })
        
        task.resume()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        centerMapOnLocation(location: initialLocation)
        postBlipsServer()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

