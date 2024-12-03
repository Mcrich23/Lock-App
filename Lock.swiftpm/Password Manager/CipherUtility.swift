//
//  CipherUtility.swift
//  Lock
//
//  Created by Morris Richman on 12/2/24.
//
// Based on https://stackoverflow.com/questions/37680361/aes-encryption-in-swift

import Foundation
import CommonCrypto
import CryptoKit

@Observable
class AES {
    enum Errors: Error {
        case unableToConvertIVToData
    }
    
    static func generateKey() throws -> Data {
        switch SecureEnclave.isAvailable {
        case true:
            try SecureEnclave.P256.Signing.PrivateKey().dataRepresentation
            case false:
            P256.Signing.PrivateKey().derRepresentation
        }
    }
    
    static func getAES() throws -> AES {
        switch SecureEnclave.isAvailable {
        case true:
            let existingKey: SecureEnclave.P256.Signing.PrivateKey? = try GenericPasswordStore().readKey(account: GenericPasswordStore.account)
            
            guard let existingKey else {
                let key = try SecureEnclave.P256.Signing.PrivateKey()
                let roundTrippedKey = try GenericPasswordStore().roundTrip(key, account: GenericPasswordStore.account)
                
                return AES(key: roundTrippedKey.dataRepresentation)
            }
            
            return AES(key: existingKey.dataRepresentation)
        case false:
            let existingKey: P256.Signing.PrivateKey? = try SecKeyStore().readKey(label: SecKeyStore.label)
            
            guard let existingKey else {
                let key = P256.Signing.PrivateKey()
                let roundTrippedKey = try SecKeyStore().roundTrip(key, label: SecKeyStore.label)
                
                return AES(key: roundTrippedKey.derRepresentation)
            }
            
            return AES(key: existingKey.derRepresentation)
        }
    }

    // MARK: - Value
    // MARK: Private
    private let key: Data


    // MARK: - Initialzier
    init?(key: String) {
        guard key.count == kCCKeySizeAES128 || key.count == kCCKeySizeAES256, let keyData = key.data(using: .utf8) else {
            debugPrint("Error: Failed to set a key.")
            return nil
        }
        
        self.key = keyData
    }
    
    init(key: Data) {
        self.key = key
    }


    // MARK: - Function
    // MARK: Public
    func encrypt(string: String) -> Data? {
        return crypt(data: string.data(using: .utf8), option: CCOperation(kCCEncrypt))
    }

    func decrypt(data: Data?) -> String? {
        guard let data = data else { return nil }
        
        // Extract the IV from the start of the data (first 16 bytes)
        let iv = data.prefix(kCCBlockSizeAES128)
        
        // Remove the IV and preamble from the data
        let dataWithoutIV = data.dropFirst(kCCBlockSizeAES128)
        let dataWithoutPreamble = dataWithoutIV
        
        // Now, decrypt the rest of the data (without IV and preamble)
        guard let decryptedData = crypt(data: dataWithoutPreamble, option: CCOperation(kCCDecrypt), iv: iv) else { return nil }
        
        return String(bytes: decryptedData, encoding: .utf8)
    }
    
    func crypt(data: Data?, option: CCOperation, iv: Data? = nil) -> Data? {
        guard let data = data else { return nil }
        
        let key = key.count == kCCKeySizeAES128 || key.count == kCCKeySizeAES256 ? self.key : self.key.prefix(kCCKeySizeAES128)
        
        // Generate a random preamble (random bits to prepend)
        let preambleSize = 16 // Define the size of the random preamble
        var preamble = Data(count: preambleSize)
        let result = preamble.withUnsafeMutableBytes {
            SecRandomCopyBytes(kSecRandomDefault, preambleSize, $0.baseAddress!)
        }
        guard result == errSecSuccess else {
            print("Error: Failed to generate random preamble.")
            return nil
        }
        
        // Combine preamble with the data for encryption
        let combinedData = option == CCOperation(kCCEncrypt) ? preamble + data : data
        
        // Generate a secure IV if it's encryption, otherwise use the provided IV for decryption
        var iv = iv ?? Data(count: kCCBlockSizeAES128)
        let ivResult = iv.withUnsafeMutableBytes {
            SecRandomCopyBytes(kSecRandomDefault, kCCBlockSizeAES128, $0.baseAddress!)
        }
        guard ivResult == errSecSuccess else {
            print("Error: Failed to generate IV.")
            return nil
        }
        
        // Allocate buffer for cryptographic result
        let cryptLength = combinedData.count + kCCBlockSizeAES128
        var cryptData = Data(count: cryptLength)
        
        var bytesLength = 0
        
        // Perform encryption or decryption
        let status = cryptData.withUnsafeMutableBytes { cryptBytes in
            combinedData.withUnsafeBytes { dataBytes in
                iv.withUnsafeBytes { ivBytes in
                    key.withUnsafeBytes { keyBytes in
                        CCCrypt(option,
                                CCAlgorithm(kCCAlgorithmAES),
                                CCOptions(kCCOptionPKCS7Padding),
                                keyBytes.baseAddress, key.count,
                                ivBytes.baseAddress,
                                dataBytes.baseAddress, combinedData.count,
                                cryptBytes.baseAddress, cryptLength,
                                &bytesLength)
                    }
                }
            }
        }
        
        guard status == kCCSuccess else {
            print("Error: Failed to crypt data. Status \(status)")
            return nil
        }
        
        cryptData.removeSubrange(bytesLength..<cryptData.count)
        
        if option == CCOperation(kCCEncrypt) {
            // Prepend the IV to the encrypted data
            return iv + cryptData
        } else {
            // For decryption, return the data without the preamble and IV (correct handling)
            return cryptData.dropFirst(preambleSize)
        }
    }
}
