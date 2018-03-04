//
//  AttractionTableObserver.swift
//  BlipsClient
//
//  Created by Cyrus Sadeghi on 2018-02-06.
//  Copyright © 2018 Cyrus Sadeghi. All rights reserved.
//

import Foundation

protocol AttractionTableObserver {
    func didUpdateSelectedRows(selected: [String])
}
