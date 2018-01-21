//
//  User.swift
//  BlipsClient
//
//  Created by Cyrus Sadeghi on 2018-01-20.
//  Copyright © 2018 Cyrus Sadeghi. All rights reserved.
//

import Foundation

class User {
    let firstName: String
    let lastName: String
    let imageURL: URL
    let email: String
    var attractionHistory: [String: Int]

    init(firstName: String, lastName: String, imageURL: URL, email: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.imageURL = imageURL
        self.email = email
        
        attractionHistory = [:] //temporary
    }
    
    func getFirstName() -> String {
        return firstName
    }
    
    func getLastName() -> String {
        return lastName
    }
    
    func getName() -> String {
        return firstName + " " + lastName
    }
    
    func getEmail() -> String {
        return email
    }
    
    func updateAttractionHistory(selections: [String]) {
        for selection in selections {
            if let _ = self.attractionHistory[selection] {
                self.attractionHistory[selection] = attractionHistory[selection]! + 1
            }
            else {
                self.attractionHistory[selection] = 1
            }
        }
    }
}
