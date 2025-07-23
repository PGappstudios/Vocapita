//
//  Item.swift
//  Vocapita
//
//  Created by Pedro Gregorio on 23/07/2025.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
