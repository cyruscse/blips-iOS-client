//
//  SavedBlipTableObserver.swift
//  BlipsClient
//
//  Created by Cyrus Sadeghi on 2018-02-25.
//  Copyright © 2018 Cyrus Sadeghi. All rights reserved.
//

import Foundation

protocol SavedBlipTableObserver {
    func blipUnsaved(blip: Blip)
    func reorderedBlips(sourceRow: Int, destinationRow: Int)
}
