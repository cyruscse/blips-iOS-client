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
    let idToken: String
    let email: String

    init(firstName: String, lastName: String, idToken: String, email: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.idToken = idToken
        self.email = email
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
    
    func getIdToken() -> String {
        return idToken
    }
    
    func getEmail() -> String {
        return email
    }
}
