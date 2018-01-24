//
//  User.swift
//  BlipsClient
//
//  Created by Cyrus Sadeghi on 2018-01-20.
//  Copyright © 2018 Cyrus Sadeghi. All rights reserved.
//

import Foundation

struct PropertyKey {
    static let firstName = "firstName"
    static let lastName = "lastName"
    static let imageURL = "imageURL"
    static let email = "email"
}

class User: NSObject, NSCoding {
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("user")
    
    private var firstName: String
    private var lastName: String
    private var imageURL: URL  //implement this...
    private var email: String
    
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
    
    // NSCoder Persistence methods
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.firstName, forKey: PropertyKey.firstName)
        aCoder.encode(self.lastName, forKey: PropertyKey.lastName)
        aCoder.encode(self.imageURL, forKey: PropertyKey.imageURL)
        aCoder.encode(self.email, forKey: PropertyKey.email)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard let fName = aDecoder.decodeObject(forKey: PropertyKey.firstName) as? String else {
            print("Failed to decode first name!")
            return nil
        }
        
        guard let lName = aDecoder.decodeObject(forKey: PropertyKey.lastName) as? String else {
            print("Failed to decode last name!")
            return nil
        }
        
        guard let iURL = aDecoder.decodeObject(forKey: PropertyKey.imageURL) as? URL else {
            print("Failed to decode image URL!")
            return nil
        }
        
        guard let eml = aDecoder.decodeObject(forKey: PropertyKey.email) as? String else {
            print("Failed to decode email!")
            return nil
        }
        
        self.init(firstName: fName, lastName: lName, imageURL: iURL, email: eml)
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
