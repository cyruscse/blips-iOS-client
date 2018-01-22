//
//  User.swift
//  BlipsClient
//
//  Created by Cyrus Sadeghi on 2018-01-20.
//  Copyright © 2018 Cyrus Sadeghi. All rights reserved.
//

import Foundation

class User {
    private let firstName: String
    private let lastName: String
    private let imageURL: URL
    private let email: String
    
    private var attractionHistory: [String: Int]
    private var userID: Int

    init(firstName: String, lastName: String, imageURL: URL, email: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.imageURL = imageURL
        self.email = email
        
        userID = 0 //temporary
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
    
    func setID(userID: Int) {
        self.userID = userID
    }
    
    func getID() -> Int {
        return userID
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
    
    func addAttractionHistory(attraction: String, frequency: Int) {
        self.attractionHistory[attraction] = frequency
    }
}
