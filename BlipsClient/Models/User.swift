//
//  User.swift
//  BlipsClient
//
//  Created by Cyrus Sadeghi on 2018-01-20.
//  Copyright © 2018 Cyrus Sadeghi. All rights reserved.
//

import Foundation
import UIKit

struct PropertyKey {
    static let firstName = "firstName"
    static let lastName = "lastName"
    static let imageURL = "imageURL"
    static let email = "email"
    static let userID = "userID"
    static let attractionHistory = "attractionHistory"
    static let guest = "guest"
}

struct AttractionHistory: Comparable, Hashable {
    static func <(lhs: AttractionHistory, rhs: AttractionHistory) -> Bool {
        return lhs.frequency > rhs.frequency
    }
    
    static func ==(lhs: AttractionHistory, rhs: AttractionHistory) -> Bool {
        return lhs.attraction == rhs.attraction
    }
    
    var attraction: String
    let frequency: Int
    
    var hashValue: Int {
        return attraction.hashValue
    }
}

class User: NSObject, NSCoding, LookupModelObserver {
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("user")
    
    private var firstName: String
    private var lastName: String
    private var imageURL: URL
    private var image: UIImage
    private var email: String
    private var attractionHistory: [String: Int]
    private var userID: Int
    private var userHistoryObservers = [UserHistoryObserver]()
    private var guest: Bool

    init(firstName: String, lastName: String, imageURL: URL, email: String, userID: Int, attractionHistory: [String: Int], guest: Bool) {
        self.firstName = firstName
        self.lastName = lastName
        self.imageURL = imageURL
        self.email = email
        self.userID = userID
        self.attractionHistory = attractionHistory
        self.guest = guest
        
        if let data = try? Data(contentsOf: imageURL) {
            self.image = UIImage(data: data)!
        }
        else {
            self.image = UIImage()
        }
    }
    
    // Standard getters and setters
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
    
    func getImage() -> UIImage {
        return image
    }
    
    func setID(userID: Int) {
        self.userID = userID
    }
    
    func getID() -> Int {
        return userID
    }
    
    func isGuest() -> Bool {
        return guest
    }
    
    func hasMadeRequests() -> Bool {
        if attractionHistory.count != 0 {
            return true
        }
        
        return false
    }
    
    func getAttractionHistory() -> [String: Int] {
        return attractionHistory
    }

    // NSCoder Persistence methods
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.firstName, forKey: PropertyKey.firstName)
        aCoder.encode(self.lastName, forKey: PropertyKey.lastName)
        aCoder.encode(self.imageURL, forKey: PropertyKey.imageURL)
        aCoder.encode(self.email, forKey: PropertyKey.email)
        aCoder.encode(self.userID, forKey: PropertyKey.userID)
        aCoder.encode(self.attractionHistory, forKey: PropertyKey.attractionHistory)
        aCoder.encode(self.guest, forKey: PropertyKey.guest)
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
        
        let id = aDecoder.decodeInteger(forKey: PropertyKey.userID)
        
        guard let history = aDecoder.decodeObject(forKey: PropertyKey.attractionHistory) as? [String: Int] else {
            print("Failed to decode attraction history!")
            return nil
        }
        
        let gst = aDecoder.decodeBool(forKey: PropertyKey.guest)

        self.init(firstName: fName, lastName: lName, imageURL: iURL, email: eml, userID: id, attractionHistory: history, guest: gst)
    }
    
    func saveUser() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(self, toFile: User.ArchiveURL.path)
        
        if isSuccessfulSave == false {
            print("Failed to save user")
        }
    }
    
    // User History observer methods
    func addUserHistoryObserver(observer: UserHistoryObserver) {
        self.userHistoryObservers.append(observer)
    }
    
    func updateHistoryListeners() {
        let orderedHistory: [AttractionHistory] = orderedAttractionHistory()
        
        // Save this object when attraction history changes
        saveUser()
        
        for observer in userHistoryObservers {
            observer.historyUpdated(attractionHistory: orderedHistory)
        }
    }
    
    func updateAttractionHistory(selections: [String]) {
        for selection in selections {
            if let _ = self.attractionHistory[selection] {
                self.attractionHistory[selection] = self.attractionHistory[selection]! + 1
            }
            else {
                self.attractionHistory[selection] = 1
            }
        }

        updateHistoryListeners()
    }
    
    func setAttractionHistory(history: [String: Int]) {
        self.attractionHistory = history
        
        updateHistoryListeners()
    }
    
    func mergeAttractionHistory(toMerge: [String: Int]) {
        self.attractionHistory.merge(toMerge, uniquingKeysWith: { first, second in return (first + second) })
    }
    
    func orderedAttractionHistory() -> [AttractionHistory] {
        var historySet: Set<AttractionHistory> = []

        for (key, value) in attractionHistory {
            historySet.insert(AttractionHistory(attraction: key, frequency: value))
        }
        
        return historySet.sorted()
    }
    
    func setAttractionTypes(attrToProperName: [String : String], properNameToAttr: [String : String], prioritySortedAttractions: [String]) {
        updateHistoryListeners()
    }
    
    
    func clearAttractionHistory() {
        self.attractionHistory = [:]
        
        updateHistoryListeners()
    }
}
