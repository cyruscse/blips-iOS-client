//
//  ServerInterface.swift
//  BlipsClient
//
//  Created by Cyrus Sadeghi on 2017-11-24.
//  Copyright © 2017 Cyrus Sadeghi. All rights reserved.
//

import UIKit

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
        let serverURL:URL = URL(string: "")!    // AWS hosted Blips Server URL removed (as server has been shut down). Update this to point to new location if server is hosted again in the future
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
                let alert = UIAlertController(title: "Server Request Failed", message: error?.localizedDescription, preferredStyle: .alert);
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                
                var rootVC = UIApplication.shared.keyWindow?.rootViewController
                
                if let navigationVC = rootVC as? UINavigationController {
                    rootVC = navigationVC.viewControllers.first
                }
                
                rootVC?.present(alert, animated: true, completion: nil)
                
                return
            }
            
            guard let data = data else {
                let alert = UIAlertController(title: "Server Request Failed", message: "Other Failure (bad data)", preferredStyle: .alert);
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                
                var rootVC = UIApplication.shared.keyWindow?.rootViewController
                
                if let navigationVC = rootVC as? UINavigationController {
                    rootVC = navigationVC.viewControllers.first
                }
                
                rootVC?.present(alert, animated: true, completion: nil)
                
                return
            }
            
            callback(data)
        })
        
        task.resume()
    }
    
    static func makeRequest(request: [String: Any], callback: @escaping (_ data: Data) -> ()) {
        do {
            try ServerInterface.postServer(jsonRequest: request, callback: { (data) in callback(data) })
        } catch ServerInterfaceError.badJSONRequest(description: let error) {
            let alert = UIAlertController(title: "Server Request Failed", message: error, preferredStyle: .alert);
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            var rootVC = UIApplication.shared.keyWindow?.rootViewController
            
            if let navigationVC = rootVC as? UINavigationController {
                rootVC = navigationVC.viewControllers.first
            }
            
            rootVC?.present(alert, animated: true, completion: nil)
            
            return
        } catch {
            let alert = UIAlertController(title: "Server Request Failed", message: "Other Failure", preferredStyle: .alert);
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            var rootVC = UIApplication.shared.keyWindow?.rootViewController
            
            if let navigationVC = rootVC as? UINavigationController {
                rootVC = navigationVC.viewControllers.first
            }
            
            rootVC?.present(alert, animated: true, completion: nil)
            
            return
        }
    }
}
