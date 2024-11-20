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
    @Environment(\.dismiss) var dismiss
    @State var isShowingIncorrectCodeAlert = false
    
    var body: some View {
        @Bindable var setup2FAController = setup2FAController
        
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
            
            ZStack(alignment: .top) {
                Button("Scan QR Code", action: showCode)
                    .buttonStyle(.borderedProminent)
                    .allowsHitTesting(!setup2FAController.isShowingOtp)
                GroupBox {
                    VStack {
                        HStack(spacing: 20) {
                            Text("One Time Code:")
                                .font(.headline)
                            Text(setup2FAController.otpText)
                            
                            if let time = setup2FAController.timeUntilNewOtp {
                                CircleCountdownView(progress: 1-((time-1)/30))
                                    .frame(width: 40, height: 40)
                                    .overlay {
                                        Text("\(30-Int(time))")
                                    }
                            }
                        }
                        
                        HStack {
                            TextField("Confirm OTP to Setup", text: $setup2FAController.enteredOtpText)
                                .textFieldStyle(.roundedBorder)
                                .onSubmit(setupOtp)
                            
                            Button("Enter", action: setupOtp)
                                .buttonStyle(.borderedProminent)
                            
                            if setup2FAController.completedTotp {
                                Button("Reset", action: reset)
                                    .buttonStyle(.bordered)
                                    .transition(.slide)
                            }
                        }
                    }
                    .frame(maxWidth: setup2FAController.completedTotp ? 400 : 350)
                }
                .offset(y: setup2FAController.isShowingOtp ? 0 : 250)
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
        .alert("Incorrect Code", isPresented: $isShowingIncorrectCodeAlert) {
            Button("Ok") {}
        } message: {
            Text("Please enter the correct code.")
        }
    }
    
    func showCode() {
        withAnimation {
            setup2FAController.isShowingOtp = true
        }
    }
    
    func setupOtp() {
        guard setup2FAController.otpText == setup2FAController.enteredOtpText else {
            isShowingIncorrectCodeAlert = true
            return
        }
        
        withAnimation {
            setup2FAController.completedTotp = true
        }
        dismiss()
    }
    
    func reset() {
        setup2FAController.completedTotp = false
        setup2FAController.isShowingOtp = false
        setup2FAController.enteredOtpText = ""
    }
}

#Preview {
    TOTPEducationView()
        .environment(Setup2FAController())
}
