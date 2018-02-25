//
//  UserLoginObserver.swift
//  BlipsClient
//
//  Created by Cyrus Sadeghi on 2018-01-20.
//  Copyright © 2018 Cyrus Sadeghi. All rights reserved.
//

import Foundation

protocol UserAccountObserver {
    func userLoggedIn(account: User)
    func userLoggedOut()
    func guestReplaced(guestQueried: Bool)
}
