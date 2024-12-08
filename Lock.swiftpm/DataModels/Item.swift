//
//  Item.swift
//  Lock
//
//  Created by Morris Richman on 12/1/24.
//

import Foundation
import SwiftData
import SwiftUI

@Model
final class Item: Identifiable {
    var id: UUID
    var name: String?
    var image: Data?
    
    var website: String
    
    var websiteURL: URL? {
        if let webUrl = URL(string: website), webUrl.scheme == nil, let url = URL(string: "https://\(website)") {
            return url
        } else if let url = URL(string: website) {
            return url
        }
        
        return nil
    }
    
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
    
    func getWebsiteIcon() async throws -> UIImage? {
        guard !website.isEmpty, let websiteURL else { throw URLError(.badURL) }
        
        let (webpageData, _) = try await URLSession.shared.data(from: websiteURL)
        guard let webpageString = String(data: webpageData, encoding: .utf8) else { return nil }
        let headBeginIndex = webpageString.index(of: "<head>")
        let headEndIndex = webpageString.index(of: "</head>")
        
        guard let headBeginIndex, let headEndIndex else { return nil }
        let headString = webpageString[headBeginIndex...headEndIndex]
        
        do {
            let pwaIcon = try await getPWAIcon(from: headString)
            
            guard let pwaIcon else {
                let favicon = try await getWebsiteFavicon(from: headString)
                
                guard let favicon else {
                    return try await getWebsiteTopLevelFavicon()
                }
                return favicon
            }
            
            return pwaIcon
        } catch {
            print(error)
            let favicon = try await getWebsiteFavicon(from: headString)
            
            guard let favicon else {
                return try await getWebsiteTopLevelFavicon()
            }
            return favicon
        }
    }
    
    private func getWebsiteTopLevelFavicon() async throws -> UIImage? {
        guard let websiteURL else { throw URLError(.badURL) }
        
        let faviconURL = websiteURL.appendingPathComponent("favicon.ico")
        
        let (faviconData, _) = try await URLSession.shared.data(from: faviconURL)
        
        return UIImage(data: faviconData)
    }
    
    private func getWebsiteFavicon(from headHtmlString: String.SubSequence) async throws -> UIImage? {
        try await getWebsiteFavicon(from: String(headHtmlString))
    }
    
    private func getWebsiteFavicon(from headHtmlString: String) async throws -> UIImage? {
        let beginIndexOfFavicon = headHtmlString.index(of: "<link rel=\"icon\"")
        guard let beginIndexOfFavicon else { return nil }
        let endIndexOfFavicon = headHtmlString[beginIndexOfFavicon...].firstIndex(of: ">")
        
        guard let endIndexOfFavicon else { return nil }
        let faviconString = headHtmlString[beginIndexOfFavicon...endIndexOfFavicon]
        
        guard let faviconURLStringBegin = faviconString.index(of: "href=\"")
        else { return nil }
        
        let faviconURLString = faviconString[faviconURLStringBegin...].replacingOccurrences(of: "href=\"", with: "").split(separator: "\"").first
        
        guard let faviconURLString,
              let faviconURL = URL(string: String(faviconURLString))
        else {
            return nil
        }
        
        let (faviconData, _) = try await URLSession.shared.data(from: faviconURL)
        
        return UIImage(data: faviconData)
    }
    
    private func getPWAIcon(from headHtmlString: String.SubSequence) async throws -> UIImage? {
        try await getPWAIcon(from: String(headHtmlString))
    }
    
    private func getPWAIcon(from headHtmlString: String) async throws -> UIImage? {
        guard let websiteURL else { return nil }
        
        let beginIndexOfManifest = headHtmlString.index(of: "<link rel=\"manifest\"")
        guard let beginIndexOfManifest else { return nil }
        let endIndexOfManifest = headHtmlString[beginIndexOfManifest...].firstIndex(of: ">")
        
        guard let endIndexOfManifest else { return nil }
        let manifestString = headHtmlString[beginIndexOfManifest...endIndexOfManifest]
        let manifestURLString = manifestString.replacingOccurrences(of: "<link rel=\"manifest\" href=\"", with: "").replacingOccurrences(of: "\"/>", with: "").replacingOccurrences(of: "\">", with: "")
        
        let manifestURL: URL
        
        if let newManifestURL = URL(string: manifestURLString), newManifestURL.scheme != nil {
            manifestURL = newManifestURL
        } else {
            manifestURL = websiteURL.appending(path: manifestURLString)
        }
        
        let (manifestData, _) = try await URLSession.shared.data(from: manifestURL)
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let manifest: WebsiteManifest = try jsonDecoder.decode(WebsiteManifest.self, from: manifestData)
        let icon = manifest.icons.sorted(by: { $0.sizes > $1.sizes }).first
        
        guard let iconURLString = icon?.src else { return nil }
        
        let iconURL: URL
        
        if let newIconURL = URL(string: iconURLString), newIconURL.scheme != nil {
            iconURL = newIconURL
        } else {
            if let startUrl = manifest.startUrl, startUrl != "/" {
                iconURL = websiteURL.appending(path: startUrl).appending(path: iconURLString)
            } else {
                iconURL = websiteURL.appending(path: iconURLString)
            }
        }
        
        let (iconData, _) = try await URLSession.shared.data(from: iconURL)
        
        return UIImage(data: iconData)
    }
    
    func setImage(_ image: UIImage?) {
        self.image = image?.pngData()
    }
    
    func resetImage() -> UIImage? {
        guard let image else { return nil }
        
        return UIImage(data: image)
    }
    
    init(id: UUID = .init(), name: String? = nil, image: Data? = nil, website: String, userName: String? = nil, notes: String = "", totpSecret: Data? = nil, password: Data? = nil) {
        self.id = id
        self.name = name
        self.image = image
        self.website = website
        self.notes = notes
        self.userName = userName
        self.totpSecret = totpSecret
        self.password = password
    }
}

extension StringProtocol {
    func index<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.lowerBound
    }
    func endIndex<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.upperBound
    }
    func indices<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Index] {
        ranges(of: string, options: options).map(\.lowerBound)
    }
    func ranges<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Range<Index>] {
        var result: [Range<Index>] = []
        var startIndex = self.startIndex
        while startIndex < endIndex,
            let range = self[startIndex...]
                .range(of: string, options: options) {
                result.append(range)
                startIndex = range.lowerBound < range.upperBound ? range.upperBound :
                    index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }
}
