//
//  Setup2FAView.swift
//  Lock
//
//  Created by Morris Richman on 11/18/24.
//

import SwiftUI

struct Setup2FAView: View {
    let timer = UpsideDownAccuteTriangle.defaultTimer
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Setup Multi-Factor Authentication")
                    .font(.title)
                    .bold()
                
                VStack(alignment: .leading) {
                    Text("Multi-Factor Authentication (MFA) is a way to add an extra layer of security to your account. It allows you to hold a second part of login that you can use to verify your identity. This makes it harder for someone to gain access to your account if they know your password.")
                }
                .padding(.top, 1)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: 600, alignment: .leading)
                
                ZStack {
                    UpsideDownAccuteTriangle(timer: timer, visibleSides: [.right])
                        .environment(\.direction, .right)
                    UpsideDownAccuteTriangle(timer: timer, visibleSides: [.left])
                        .environment(\.direction, .left)
                }
                .frame(width: 200, height: 200)
                .overlay(alignment: .topLeading) {
                    Image(systemName: "key.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                        .foregroundStyle(Color.accentColor)
                        .background(Color(uiColor: .systemBackground))
                        .offset(x: -12, y: -12)
                }
                .overlay(alignment: .topTrailing) {
                    Image(systemName: "key.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                        .foregroundStyle(Color.accentColor)
                        .background(Color(uiColor: .systemBackground))
                        .offset(x: 20, y: -12)
                }
                .overlay(alignment: .bottom) {
                    Image(systemName: "lock.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                        .foregroundStyle(Color.green)
                        .background(
                            Color(uiColor: .systemBackground)
                                .frame(width: 25, height: 25)
                                .clipShape(Circle())
                                .offset(y: -12)
                        )
                        .offset(x: 3, y: 30)
                }
                .scaleEffect(0.7)
            }
            
            MFANavigationLink(image: Image(systemName: "text.bubble"), title: "SMS Text Message", description: "Send a your phone a text message containing the MFA code") {
                Text("Setup SMS Message")
            }
            
            MFANavigationLink(image: Image(systemName: "lock.app.dashed"), title: "Authenticator App", description: "Have a rotating set of codes displayed on your phone inside an authenticator app") {
                Text("Setup Authenticator App")
            }
            
            MFANavigationLink(image: Image(systemName: "person.badge.key"), title: "Passkeys", description: "Authenticate with an application or website through Passkeys and FaceID") {
                Text("Setup Passkeys")
            }
        }
    }
}

private struct MFANavigationLink<Content: View>: View {
    let image: Image
    let title: String
    let description: String?
    @ViewBuilder var destination: Content
    @Namespace var namespace
    
    var body: some View {
        GroupBox {
            NavigationLink {
                destination
                    .navigationTransition(.zoom(sourceID: "auth", in: namespace))
            } label: {
                HStack(spacing: 20) {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 40)
                    
                    VStack(alignment: .leading) {
                        Text(title)
                            .font(.headline)
                        if let description {
                            Text(description)
                                .foregroundStyle(Color.primary)
                        }
                    }
                }
            }
            .frame(maxWidth: 700, alignment: .leading)
        }
        .matchedTransitionSource(id: "auth", in: namespace)
    }
}

#Preview {
    Setup2FAView()
}
