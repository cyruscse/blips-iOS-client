//
//  LookupModel.swift
//  BlipsClient
//
//  Created by Cyrus Sadeghi on 2017-11-24.
//  Copyright © 2017 Cyrus Sadeghi. All rights reserved.
//

import Foundation

class LookupModel {
    let session = URLSession.shared
    let url:URL = URL(string: "http://www.blipsserver-env.us-east-2.elasticbeanstalk.com")!
    let jsonRequest = ["requestType": "dbsync"]
    
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

    func getLookupAttributes(jsonRequest: [String: String]) {
        print (jsonRequest)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: jsonRequest, options: .prettyPrinted)
        } catch let error {
            print (error.localizedDescription)
            
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
                print(serverResponse)
            }
        })
        
        task.resume()
    }
    
    func syncWithServer() {
        getLookupAttributes(jsonRequest: jsonRequest)
    }
}
