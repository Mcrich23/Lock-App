//
//  WebsiteManifest.swift
//  Lock
//
//  Created by Morris Richman on 12/7/24.
//

import Foundation

struct WebsiteManifest: Codable {
    let icons: [Icon]
    let startUrl: String?
    
    struct Icon: Codable {
        let src: String
        let sizes: String
        let type: String
    }
}
