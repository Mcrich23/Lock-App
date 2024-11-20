//
//  Setup2FAController.swift
//  Lock
//
//  Created by Morris Richman on 11/19/24.
//

import Foundation
import CryptoKit
import CommonCrypto
import CoreImage
import UIKit

@Observable
class Setup2FAController {
    // MARK: SMS
    var completedSms: Bool = false
    var smsIsShowingNotification = false
    var smsCodeText = ""
    
    // MARK: TOTP
    var completedTotp: Bool = false
    var isShowingOtp = false
    var enteredOtpText = ""
    private(set) var otpText = ""
    
    private(set) var timeUntilNewOtp: TimeInterval?
    
    private var totpSecretText = UUID().uuidString
    func updateTotp() {
        let period = TimeInterval(30)
        let digits = 6
        guard let secret = totpSecretText.data(using: .utf8) else { return }
        var counter = UInt64(Date().timeIntervalSince1970 / period).bigEndian

        // Generate the key based on the counter.
        let key = SymmetricKey(data: Data(bytes: &counter, count: MemoryLayout.size(ofValue: counter)))
        let hash = HMAC<Insecure.SHA1>.authenticationCode(for: secret, using: key)

        var truncatedHash = hash.withUnsafeBytes { ptr -> UInt32 in
            let offset = ptr[hash.byteCount - 1] & 0x0f

            let truncatedHashPtr = ptr.baseAddress! + Int(offset)
            return truncatedHashPtr.bindMemory(to: UInt32.self, capacity: 1).pointee
        }

        truncatedHash = UInt32(bigEndian: truncatedHash)
        truncatedHash = truncatedHash & 0x7FFF_FFFF
        truncatedHash = truncatedHash % UInt32(pow(10, Float(digits)))

        let otpText = String(format: "%0*u", digits, truncatedHash)
        
        let timeElapsed = Date().timeIntervalSince1970.truncatingRemainder(dividingBy: period)
        self.timeUntilNewOtp = (period - timeElapsed)+1
        
        guard otpText != self.otpText else {
            return
        }
        self.otpText = otpText
    }
    
    func generateTotpQRCode(size: CGSize = .init(width: 400, height: 400)) -> UIImage? {
        guard let data = totpSecretText.data(using: .ascii) else { return nil }
        
        let filter = CIFilter(name: "CIQRCodeGenerator")
        filter?.setValue(data, forKey: "inputMessage")
        filter?.setValue("H", forKey: "inputCorrectionLevel")
        
        guard let outputImage = filter?.outputImage else { return nil }
        
        // Scale the QR code image to the desired size
        let scaleX = size.width / outputImage.extent.size.width
        let scaleY = size.height / outputImage.extent.size.height
        
        let scaledImage = outputImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
        
        // Convert to UIImage
        let context = CIContext()
        guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) else { return nil }
        
        return UIImage(cgImage: cgImage)
    }
    
    // MARK: Passkeys
    var completedPasskeys: Bool = false
}

import SwiftUI
#Preview {
    TOTPEducationView()
        .environment(Setup2FAController())
}
