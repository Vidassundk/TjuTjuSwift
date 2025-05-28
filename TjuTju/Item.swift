//
//  Item.swift
//  TjuTju
//
//  Created by Vidas Sun on 28/05/2025.
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
