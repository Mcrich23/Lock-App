//
//  SMSEducationView.swift
//  Lock
//
//  Created by Morris Richman on 11/18/24.
//

import SwiftUI

struct SMSEducationView: View {
    @Environment(Setup2FAController.self) var setup2FAController
    let timer = UpsideDownAccuteTriangle.defaultTimer
    let smsCode = "110843"
    @Namespace var namespace
    @Namespace var keyboardNamespace
    @Environment(\.dismiss) var dismiss
    @State var isShowingIncorrectCodeAlert = false
    @FocusState var isEnteringCode: Bool
    
    var body: some View {
        VStack {
            if UIDevice.current.userInterfaceIdiom == .pad {
                Spacer()
            }
            Text("Multi-Factor Authentication: SMS Text Message")
                .font(.title)
                .bold()
                .multilineTextAlignment(.center)
            Text("In the early stages of multi-factor authentication, SMS codes were revolutionary. You receive a text message with a code that you need to enter to complete the login process.")
                .padding(.top, 1)
            
            smsCodeGraphic
            
            VStack(alignment: .leading) {
                Text("The Downside of This")
                    .font(.title3)
                    .bold()
                
                Text("Unfortunately, SMS is not very *secure*. It is easy to intercept the text message, and prevent the message from being sent. This allows hackers to gain access to your account without your knowledge.")
            }
                .frame(maxWidth: 755, alignment: .leading)
            smsCodeHackerGraphic
                .padding(.top, 15)
//                .padding(.bottom, 60)
//                .padding(.bottom)
            
            Spacer()
        }
        .frame(maxWidth: 800)
        .overlay(alignment: .top) {
            NotificationAlertView(title: "81961", subtitle: "Your SMS Code is: \(smsCode). Don't share it with anyone.", time: "Now")
                .shadow(radius: 10, y: 3)
                .offset(y: setup2FAController.smsIsShowingNotification ? 0 : -220)
        }
        .ignoresSafeArea(.keyboard)
        .overlay(alignment: .bottom, content: {
            Group {
                if setup2FAController.smsIsShowingNotification {
                    HStack {
                        @Bindable var setup2FAController = setup2FAController
                        TextField("Enter Code", text: $setup2FAController.smsCodeText)
                            .keyboardType(.numberPad)
                            .textFieldStyle(.roundedBorder)
                            .onSubmit(checkCode)
                            .focused($isEnteringCode)
                            .frame(maxWidth: 150)
                            .padding(.trailing, 5)
                        Button("Enter", action: checkCode)
                            .buttonStyle(.borderedProminent)
                            .buttonBorderShape(.roundedRectangle(radius: 6))
                            .background(
                                Color(uiColor: .systemBackground)
                                    .clipShape(RoundedRectangle(cornerRadius: 6))
                            )
                            .background(alignment: setup2FAController.completedSms ? .trailing : .center) {
                                Button("Reset", action: reset)
                                    .fixedSize()
                                    .buttonStyle(.bordered)
                                    .buttonBorderShape(.roundedRectangle(radius: 6))
                                    .background(
                                        Color(uiColor: .systemBackground)
                                            .clipShape(RoundedRectangle(cornerRadius: 6))
                                    )
                                    .opacity(setup2FAController.completedSms ? 1 : 0)
                                    .offset(x: setup2FAController.completedSms ? 75 : 0)
                            }
                    }
                    .matchedGeometryEffect(id: "smsCode", in: namespace)
                } else {
                    Button("Setup") {
                        withAnimation {
                            setup2FAController.smsIsShowingNotification = true
                        }
                    }
                    .buttonStyle(.bordered)
                    .matchedGeometryEffect(id: "smsCode", in: namespace)
                }
            }
            .padding(.vertical)
            .padding(.bottom)
        })
        .alert("Incorrect Code", isPresented: $isShowingIncorrectCodeAlert) {
            Button("Ok") {}
        } message: {
            Text("Please enter the correct code.")
        }
        .padding(.horizontal)
    }
    
    var smsCodeGraphic: some View {
        HStack(spacing: 220) {
            Image(systemName: "text.bubble")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50, height: 50)
                .background(
                    Color(uiColor: .systemBackground)
                    .frame(width: 50, height: 50)
                )
            
            Image(systemName: "iphone.gen3")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50, height: 50)
                .background(
                    Color(uiColor: .systemBackground)
                        .frame(width: 30, height: 50)
                )
        }
        .background(
            UpsideDownAccuteTriangle(timer: timer, visibleSides: [.top])
                .frame(width: 260, height: 260)
                .offset(y: 115)
        )
    }
    
    var smsCodeHackerGraphic: some View {
        UpsideDownAccuteTriangle(timer: timer, visibleSides: [.left, .right])
            .environment(\.direction, .left)
            .frame(width: 160, height: 160)
            .overlay(alignment: .topLeading) {
                Image(systemName: "text.bubble")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
                    .background(
                        Color(uiColor: .systemBackground)
                        .frame(width: 50, height: 50)
                        .offset(x: -4, y: -12)
                    )
                    .offset(x: -33, y: -5)
            }
            .overlay(alignment: .topTrailing) {
                Image(systemName: "iphone.gen3")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
                    .background(
                        Color(uiColor: .systemBackground)
                        .frame(width: 50, height: 50)
                        .offset(x: 3, y: -3)
                    )
                    .offset(x: 30, y: -12)
            }
            .overlay(alignment: .trailing) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
                    .symbolRenderingMode(.multicolor)
                    .offset(x: -15, y: 15)
            }
            .overlay(alignment: .bottom) {
                Image(systemName: "person.badge.shield.exclamationmark")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 77, height: 77)
                    .foregroundStyle(Color.red)
                    .background(
                        Color(uiColor: .systemBackground)
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                            .offset(x: -8, y: -10)
                    )
                    .offset(x: 13, y: 68)
            }
    }
    
    func checkCode() {
        guard setup2FAController.smsCodeText == smsCode else {
            isShowingIncorrectCodeAlert.toggle()
            return
        }
        
        withAnimation {
            setup2FAController.completedSms = true
        }
        dismiss()
    }
    
    func reset() {
        withAnimation {
            setup2FAController.smsCodeText = ""
            setup2FAController.smsIsShowingNotification = false
            setup2FAController.completedSms = false
        }
    }
}

#Preview {
    SMSEducationView()
        .environment(Setup2FAController())
}
