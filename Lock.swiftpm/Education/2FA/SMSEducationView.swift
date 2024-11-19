//
//  SMSEducationView.swift
//  Lock
//
//  Created by Morris Richman on 11/18/24.
//

import SwiftUI

struct SMSEducationView: View {
    let timer = UpsideDownAccuteTriangle.defaultTimer
    
    var body: some View {
        VStack {
            Text("Multi-Factor Authentication: SMS Text Message")
                .font(.title)
                .bold()
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
        }
        .frame(maxWidth: 800)
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
//                    .background(
//                        Color(uiColor: .systemBackground)
//                        .frame(width: 50, height: 50)
//                        .offset(x: 3, y: -3)
//                    )
                    .offset(x: -15, y: 15)
//                    .rotationEffect(.degrees(-65))
//                Rectangle()
//                    .frame(width: 6, height: 50)
//                    .rotationEffect(.degrees(-30))
//                    .offset(x: -33, y: 15)
//                    .foregroundStyle(.red)
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
}

#Preview {
    SMSEducationView()
}
