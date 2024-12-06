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
    var userName: String?
    private(set) var password: Data?
    private(set) var totpSecret: Data?
    
    func readPassword(from aes: AES) -> String? {
        guard let password else { return nil }
        
        return aes.decrypt(data: password)
    }
    
    func setPassword(_ password: String?, using aes: AES) {
        guard let password else {
            self.password = nil
            return
        }
        
        let encryption = aes.encrypt(string: password)
        self.password = encryption
    }
    
    func readTotpSecret(from aes: AES) -> String? {
        guard let totpSecret else { return nil }
        
        return aes.decrypt(data: totpSecret)
    }
    
    func setTotpSecret(_ totpSecret: String?, using aes: AES) {
        guard let totpSecret else {
            self.totpSecret = nil
            return
        }
        
        let encryption = aes.encrypt(string: totpSecret)
        self.totpSecret = encryption
    }
    
    init(id: UUID = .init(), name: String? = nil, website: String, userName: String? = nil, notes: String = "", totpSecret: Data? = nil, password: Data? = nil) {
        self.id = id
        self.name = name
        self.website = website
        self.notes = notes
        self.userName = userName
        self.totpSecret = totpSecret
        self.password = password
    }
}
