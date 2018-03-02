//
//  BlipDetailObserver.swift
//  BlipsClient
//
//  Created by Cyrus Sadeghi on 2018-02-24.
//  Copyright © 2018 Cyrus Sadeghi. All rights reserved.
//

import Foundation

protocol BlipDetailObserver {
    func blipSaved(blip: Blip)
    func blipUnsaved(placeID: String)
}
