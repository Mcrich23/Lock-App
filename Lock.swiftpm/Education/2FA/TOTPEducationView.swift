//
//  TOTPEducationView.swift
//  Lock
//
//  Created by Morris Richman on 11/19/24.
//

import SwiftUI

struct TOTPEducationView: View {
    @Environment(Setup2FAController.self) var setup2FAController
    let timer = Timer.publish(every: 0.001, on: .main, in: .common).autoconnect()
    @State var qrCode: UIImage?
    
    var body: some View {
        VStack {
            Text("Multi-Factor Authentication: Authenticator App")
                .font(.title)
                .bold()
                .multilineTextAlignment(.center)
            Text("Since the invention of SMS MFA, Time-Based One Time Passcodes (TOTP) have become the most popular method of authentication. It provides a unique code based on a private key and time, often every 30 seconds. This private key is often imported with a QR code.")
            
            if let qrCode {
                Image(uiImage: qrCode)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 400, maxHeight: 400)
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 400, maxHeight: 400)
            }
            
            ZStack {
                Button("Scan QR Code", action: showCode)
                    .buttonStyle(.borderedProminent)
                    .rotation3DEffect(.degrees(setup2FAController.isShowingOtp ? 90 : 0), axis: (x: 1, y: 0, z: 0))
                    .offset(y: setup2FAController.isShowingOtp ? -25 : 0)
                    .allowsHitTesting(!setup2FAController.isShowingOtp)
                HStack(spacing: 20) {
                    Text(setup2FAController.otpText)
                    
                    if let time = setup2FAController.timeUntilNewOtp {
                        CircleCountdownView(progress: 1-((time-1)/30))
                            .frame(width: 40, height: 40)
                            .overlay {
                                Text("\(30-Int(time))")
                            }
                    }
                }
                .offset(y: setup2FAController.isShowingOtp ? 0 : 100)
                .rotation3DEffect(.degrees(setup2FAController.isShowingOtp ? 0 : -90), axis: (x: 1, y: 0, z: 0))
                .allowsHitTesting(setup2FAController.isShowingOtp)
            }
        }
        .frame(maxWidth: 800)
        .onReceive(timer) { _ in
            setup2FAController.updateTotp()
        }
        .onAppear {
            self.qrCode = setup2FAController.generateTotpQRCode(size: CGSize(width: 400, height: 400))
        }
    }
    
    func showCode() {
        withAnimation {
            setup2FAController.isShowingOtp = true
        }
    }
}

#Preview {
    TOTPEducationView()
        .environment(Setup2FAController())
}
