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
    static let autoQueryOptions = "autoQueryOptions"
    static let savedBlips = "savedBlips"
}

class User: NSObject, NSCoding, LookupModelObserver, QueryOptionsObserver, BlipDetailObserver, SavedBlipTableObserver {
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

    var autoQueryOptions: AutoQueryOptions
    var lastQuery: CustomLookup!
    var signInModel: SignInModel!
    var savedBlips: [Blip]!
    
    init(firstName: String, lastName: String, imageURL: URL, email: String, userID: Int, attractionHistory: [String: Int], guest: Bool, autoQueryOptions: AutoQueryOptions, savedBlips: [Blip]) {
        self.firstName = firstName
        self.lastName = lastName
        self.imageURL = imageURL
        self.email = email
        self.userID = userID
        self.attractionHistory = attractionHistory
        self.guest = guest
        self.autoQueryOptions = autoQueryOptions
        self.savedBlips = savedBlips
        
        if let data = try? Data(contentsOf: imageURL) {
            self.image = UIImage(data: data)!
        }
        else {
            self.image = UIImage()
        }
    }

    // Guest account initialization (default values)
    convenience override init() {
        let queryOptions = AutoQueryOptions(autoQueryEnabled: true, autoQueryTypeGrabLength: 0, autoQueryOpenNow: true, autoQueryRating: 0.0, autoQueryPriceRange: 0)
        self.init(firstName: "", lastName: "", imageURL: URL(string: ".")!, email: "", userID: -1, attractionHistory: [:], guest: true, autoQueryOptions: queryOptions, savedBlips: [Blip]())
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
    
    func getAttractionHistory() -> [String: Int] {
        return attractionHistory
    }
    
    func getAttractionHistoryCount() -> Int {
        return attractionHistory.count
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
        aCoder.encode(self.autoQueryOptions, forKey: PropertyKey.autoQueryOptions)
        aCoder.encode(self.savedBlips, forKey: PropertyKey.savedBlips)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let fName = aDecoder.decodeObject(forKey: PropertyKey.firstName) as! String
        let lName = aDecoder.decodeObject(forKey: PropertyKey.lastName) as! String
        let iURL = aDecoder.decodeObject(forKey: PropertyKey.imageURL) as! URL
        let eml = aDecoder.decodeObject(forKey: PropertyKey.email) as! String
        let id = aDecoder.decodeInteger(forKey: PropertyKey.userID)
        let history = aDecoder.decodeObject(forKey: PropertyKey.attractionHistory) as! [String: Int]
        let gst = aDecoder.decodeBool(forKey: PropertyKey.guest)
        let queryOptions = aDecoder.decodeObject(forKey: PropertyKey.autoQueryOptions) as! AutoQueryOptions
        let saved = aDecoder.decodeObject(forKey: PropertyKey.savedBlips) as! [Blip]

        self.init(firstName: fName, lastName: lName, imageURL: iURL, email: eml, userID: id, attractionHistory: history, guest: gst, autoQueryOptions: queryOptions, savedBlips: saved)
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
        
        if autoQueryOptions.autoQueryTypeGrabLength == 0 {
            if attractionHistory.count > 3 {
                autoQueryOptions.autoQueryTypeGrabLength = 3
            } else {
                autoQueryOptions.autoQueryTypeGrabLength = attractionHistory.count
            }
            
            attractionTypesChanged(value: autoQueryOptions.autoQueryTypeGrabLength)
        }

        updateHistoryListeners()
    }
    
    func setAttractionHistory(history: [String: Int]) {
        self.attractionHistory = history
        
        updateHistoryListeners()
    }
    
    func mergeAttractionHistory(toMerge: [String: Int], savedToMerge: [Blip]) {
        self.attractionHistory.merge(toMerge, uniquingKeysWith: { first, second in return (first + second) })
        
        let mergedSavedBlips = Array(Set(self.savedBlips + savedToMerge))
        self.savedBlips = mergedSavedBlips
    }
    
    func orderedAttractionHistory() -> [AttractionHistory] {
        var historySet: Set<AttractionHistory> = []

        for (key, value) in attractionHistory {
            historySet.insert(AttractionHistory(attraction: key, frequency: value))
        }
        
        return historySet.sorted()
    }
    
    // LookupModelObserver Methods
    
    func setAttractionTypes(attrToProperName: [String : String], properNameToAttr: [String : String], prioritySortedAttractions: [String]) {
        updateHistoryListeners()
    }
    
    func gotGoogleClientKey(key: String) {}
    
    func clearAttractionHistoryAndSettings() {
        self.attractionHistory = [:]
        self.autoQueryOptions = AutoQueryOptions()
        self.savedBlips = [Blip]()
        
        updateHistoryListeners()
    }
    
    // LookupModelObserver Methods end
    
    // QueryOptionsObserver Methods
    
    func setAutoQueryOptions(options: AutoQueryOptions) {
        autoQueryOptions = options
        saveUser()
    }

    func attractionTypesChanged(value: Int) {
        autoQueryOptions.autoQueryTypeGrabLength = value
        signInModel.updateServerAutoQueryOptions(enabled: nil, typeGrabLength: value, openNow: nil, rating: nil, priceRange: nil)
        saveUser()
    }
    
    func autoQueryStatusChanged(enabled: Bool) {
        autoQueryOptions.autoQueryEnabled = enabled
        signInModel.updateServerAutoQueryOptions(enabled: enabled, typeGrabLength: nil, openNow: nil, rating: nil, priceRange: nil)
        saveUser()
    }
    
    func openNowChanged(value: Bool) {
        autoQueryOptions.autoQueryOpenNow = value
        signInModel.updateServerAutoQueryOptions(enabled: nil, typeGrabLength: nil, openNow: value, rating: nil, priceRange: nil)
        saveUser()
    }
    
    func ratingChanged(rating: Double) {
        autoQueryOptions.autoQueryRating = rating
        signInModel.updateServerAutoQueryOptions(enabled: nil, typeGrabLength: nil, openNow: nil, rating: rating, priceRange: nil)
        saveUser()
    }
    
    func priceChanged(price: Int) {
        autoQueryOptions.autoQueryPriceRange = price
        signInModel.updateServerAutoQueryOptions(enabled: nil, typeGrabLength: nil, openNow: nil, rating: nil, priceRange: price)
        saveUser()
    }
    
    // QueryOptionsObserver Methods end
    func blipIsSaved(placeID: String) -> Bool {
        for blip in savedBlips {
            if blip.placeID == placeID {
                return true
            }
        }
        
        return false
    }
    
    func blipSaved(blip: Blip) {
        savedBlips.append(blip)
        signInModel.serverSaveBlip(blip: blip, save: true)
        saveUser()
    }
    
    func blipUnsaved(placeID: String) {
        for blip in savedBlips {
            if blip.placeID == placeID {
                if let idx = savedBlips.index(of: blip) {
                    savedBlips.remove(at: idx)
                    signInModel.serverSaveBlip(blip: blip, save: false)
                    saveUser()
                    
                    return
                }
            }
        }
    }
    
    func setSavedBlips(savedBlips: [Blip]) {
        self.savedBlips = savedBlips
        saveUser()
    }
    
    // SavedBlipTableObserver Methods
    
    func blipUnsaved(blip: Blip) {
        for loopBlip in savedBlips {
            if loopBlip.placeID == blip.placeID {
                savedBlips.remove(at: savedBlips.index(of: loopBlip)!)
            }
        }
        
        signInModel.serverSaveBlip(blip: blip, save: false)
        saveUser()
    }
    
    // SavedBlipTableObserver Methods end
}
