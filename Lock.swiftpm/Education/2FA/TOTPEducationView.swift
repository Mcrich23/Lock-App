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
    @State var qrCodeAnimationBarValue: CGFloat = 0
    @State var qrCodeAnimationGridValue: CGFloat = 0
    @State var isShowingQRCodeAnimationMovingDown = false
    @State var isShowingQRCodeAnimation = false
    let qrAnimationSpeed = 2.0
    var qrAnimation: Animation { .easeInOut.speed(qrAnimationSpeed) }
    
    var qrCodeSquareStack: some View {
        HStack(spacing: 0) {
            ForEach(0..<4) { i in
                Rectangle()
                    .fill(Color.clear)
                    .stroke(Color.accentColor, lineWidth: 4)
            }
        }
    }
    
    var body: some View {
        @Bindable var setup2FAController = setup2FAController
        
        VStack {
            Text("Multi-Factor Authentication: Authenticator App")
                .font(.title)
                .bold()
                .multilineTextAlignment(.center)
            Text("Since the invention of SMS MFA, Time-Based One Time Passcodes (TOTP) have become the most popular method of authentication. It provides a unique code based on a private key and time, often every 30 seconds. This private key is often imported with a QR code.")
            
            GeometryReader { geo in
                VStack {
                    if let qrCode {
                        Image(uiImage: qrCode)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } else {
                        Image(systemName: "photo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    }
                }
                .overlay {
                    VStack(spacing: 0) {
//                        qrCodeSquareStack
//                            .opacity((qrCodeAnimationGridValue > 0.75 && qrCodeAnimationGridValue <= 1.1) ? 1 : 0)
//                        qrCodeSquareStack
//                            .opacity((qrCodeAnimationGridValue > 0.5 && qrCodeAnimationGridValue <= 1.1) ? 1 : (qrCodeAnimationGridValue > 0.75 && qrCodeAnimationGridValue <= 1) ? 0.5 : 0)
//                            .opacity((qrCodeAnimationGridValue > 0.25 && qrCodeAnimationGridValue <= 1.1) ? 1 : (qrCodeAnimationGridValue > 0.5 && qrCodeAnimationGridValue <= 0.75) ? 0.5 : 0)
//                        qrCodeSquareStack
//                            .opacity((qrCodeAnimationGridValue > 0 && qrCodeAnimationGridValue <= 1.1) ? 1 : (qrCodeAnimationGridValue > 0.25 && qrCodeAnimationGridValue <= 0.5) ? 0.5 : 0)
                        ForEach(Array(1...4), id: \.self) { i in
                            HStack(spacing: 0) {
                                ForEach(0..<4) { i in
                                    Rectangle()
                                        .fill(Color.clear)
                                        .stroke(Color.accentColor, lineWidth: 4)
                                }
                            }
                            .opacity(qrCodeAnimationGridValue == (Double(i)*0.25) ? 1 : (qrCodeAnimationGridValue >= (Double(i)*0.25) && qrCodeAnimationGridValue <= (Double(i+1)*0.28)) ? 0.5 : 0)
                        }
                    }
                    .frame(width: geo.size.width, height: geo.size.height)
                    .rotation3DEffect(.degrees(isShowingQRCodeAnimationMovingDown ? 0 : 180), axis: (x: 0, y: 0, z: 1))
                }
                .overlay {
                    Capsule()
                        .fill(Color.accentColor)
                        .frame(width: geo.size.width+50, height: 15)
                        .offset(y: (geo.size.height/2) - geo.size.height*qrCodeAnimationBarValue)
                        .opacity(isShowingQRCodeAnimation ? 1 : 0)
                        .rotation3DEffect(.degrees(isShowingQRCodeAnimationMovingDown ? 180 : 0), axis: (x: 0, y: 0, z: 1))
                }
            }
            .frame(maxWidth: 400, maxHeight: 400)
            
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
                .offset(y: setup2FAController.isShowingOtp ? 0 : -300)
                .opacity(setup2FAController.isShowingOtp ? 1 : 0)
                .allowsHitTesting(setup2FAController.isShowingOtp)
            }
        }
        .frame(maxWidth: 800)
        .padding()
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
    
    private func scanQRCodeUp() async {
        withAnimation(.easeInOut.speed(qrAnimationSpeed/8)) {
            qrCodeAnimationBarValue = 1
        }
        
        try? await Task.sleep(for: .milliseconds(200/qrAnimationSpeed))
        
        await withCheckedContinuation { continuation in
            withAnimation(qrAnimation) {
                isShowingQRCodeAnimation = true
            } completion: {
                withAnimation(.easeInOut.speed(qrAnimationSpeed/8)) {
                    qrCodeAnimationBarValue = 1.05
                }
                withAnimation(qrAnimation) {
                    qrCodeAnimationGridValue = 0.25
                } completion: {
                    withAnimation(qrAnimation) {
                        qrCodeAnimationGridValue = 0.5
                    } completion: {
                        withAnimation(qrAnimation) {
                            qrCodeAnimationGridValue = 0.75
                        } completion: {
                            withAnimation(qrAnimation) {
                                qrCodeAnimationGridValue = 1.0
                            } completion: {
                                withAnimation(qrAnimation) {
                                    qrCodeAnimationGridValue = 1.2
                                } completion: {
                                    withAnimation(qrAnimation) {
                                        qrCodeAnimationGridValue = 1.5
                                    } completion: {
                                        continuation.resume()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func showCode() {
        Task {
            self.isShowingQRCodeAnimationMovingDown = false
            qrCodeAnimationBarValue = 0
            await scanQRCodeUp()
            try? await Task.sleep(for: .milliseconds(750/qrAnimationSpeed))
            self.isShowingQRCodeAnimationMovingDown = true
            self.qrCodeAnimationGridValue = 0
            self.qrCodeAnimationBarValue = -0.05
            withAnimation(.easeInOut.speed(qrAnimationSpeed/7.5)) {
                qrCodeAnimationBarValue = 0.75
            }
//            try? await Task.sleep(for: .milliseconds(45/qrAnimationSpeed))
            Task {
                try? await Task.sleep(for: .milliseconds(850/qrAnimationSpeed))
                withAnimation(.easeInOut.speed(0.7)) {
                    setup2FAController.isShowingOtp = true
                    qrCodeAnimationGridValue = 0
                    isShowingQRCodeAnimation = false
                }
            }
            await scanQRCodeUp()
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
