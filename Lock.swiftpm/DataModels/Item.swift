//
//  Item.swift
//  Lock
//
//  Created by Morris Richman on 12/1/24.
//

import Foundation
import SwiftData

@Model
final class Item: Identifiable {
    var id: UUID
    var name: String?
    var website: String
    var notes: String
    var totpSecret: String?
    var userName: String?
    
    init(id: UUID = .init(), name: String? = nil, website: String, userName: String? = nil, notes: String = "", totpSecret: String? = nil) {
        self.id = id
        self.name = name
        self.website = website
        self.notes = notes
        self.userName = userName
        self.totpSecret = totpSecret
    }
}
