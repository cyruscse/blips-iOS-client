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
    
    let jsonRequest = ["cityID": "5", "type": "lodging"]
    let session = URLSession.shared
    let url:URL = URL(string: "http://www.blipsserver-env.us-east-2.elasticbeanstalk.com")!
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius, regionRadius)
        
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func readJSON(data: Data) {
        do {
            let json = try JSONSerialization.jsonObject(with: data)
            
            if let dictionary = json as? [String: Any] {
                if let array = dictionary["blip"] as? NSArray {
                    print(array[0])
                    
                    let blipDict = array[0] as! Dictionary<String, Any>

                    for (key, value) in blipDict {
                        print(key)
                        print(value)
                    }
                    
                    print(blipDict["state"])
                }
            }
        } catch {
            print (error.localizedDescription)
        }
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
            
            self.readJSON(data: data)
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

