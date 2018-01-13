//
//  ServerInterface.swift
//  BlipsClient
//
//  Created by Cyrus Sadeghi on 2017-11-24.
//  Copyright © 2017 Cyrus Sadeghi. All rights reserved.
//

import Foundation

enum ServerInterfaceError: Error {
    case badJSONRequest(description: String)
    case badResponseFromServer(description: String)
    case JSONParseFailed(description: String)
}

class ServerInterface {
    static func readJSON(data: Data) throws -> Dictionary<String, Any> {
        let json = try JSONSerialization.jsonObject(with: data)
        
        if let dictionary = json as? [String: Any] {
            return dictionary
        }
        
        throw ServerInterfaceError.JSONParseFailed(description: "Failed to parse JSON")
    }
    
    static func postServer(jsonRequest: [String: Any], callback: @escaping (Data) -> ()) throws {
        let serverURL:URL = URL(string: "http://www.blipsserver-env.us-east-2.elasticbeanstalk.com")!
        let session = URLSession.shared
        
        var request = URLRequest(url: serverURL)
        request.httpMethod = "POST"
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: jsonRequest, options: .prettyPrinted)
        } catch let error {
            throw ServerInterfaceError.badJSONRequest(description: error.localizedDescription)
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = session.dataTask(with: request as URLRequest, completionHandler : { data, response, error in
            guard error == nil else {
                return
            }
            
            guard let data = data else {
                // what is this case for? look this up
                return
            }
            
            callback(data)
        })
        
        task.resume()
    }
}
