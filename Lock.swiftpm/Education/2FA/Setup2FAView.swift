//
//  Setup2FAView.swift
//  Lock
//
//  Created by Morris Richman on 11/18/24.
//

import SwiftUI

struct MFAEductionView: View {
    let isShowingMFA: Bool
    @State var isShowingMainView: Bool = false
    
    var body: some View {
        if isShowingMainView {
            Setup2FAView()
                .transition(.blurReplace)
        } else {
            MFAEducationIntroView(isShowingMainView: $isShowingMainView, isShowingMFA: isShowingMFA)
                .transition(.blurReplace)
        }
    }
}

struct MFAEducationIntroView: View {
    @State var showSetupText1 = false
    @State var showSetupText2 = false
    @Binding var isShowingMainView: Bool
    let isShowingMFA: Bool
    
    var body: some View {
        VStack {
            Image(systemName: "person.badge.shield.exclamationmark")
                .resizable()
                .frame(width: 75, height: 75)
                .foregroundStyle(Color.red)
            Text("You were Hacked...")
                .opacity(showSetupText1 ? 1 : 0)
            Text("Lets Fix It")
                .opacity(showSetupText2 ? 1 : 0)
        }
        .onChange(of: isShowingMFA, { oldValue, newValue in
            guard newValue else { return }
            
            Task {
                try? await Task.sleep(for: .seconds(2))
                withAnimation {
                    showSetupText1 = true
                }
                try? await Task.sleep(for: .seconds(2))
                withAnimation {
                    showSetupText2 = true
                }
                try? await Task.sleep(for: .seconds(2))
                withAnimation(.default.speed(0.5)) {
                    isShowingMainView = true
                }
            }
        })
    }
}

private struct Setup2FAView: View {
    let timer = UpsideDownAccuteTriangle.defaultTimer
    @State var isShowingMFAGraphic: Bool = false
    @State var isShowingMFA1: Bool = false
    @State var isShowingMFA2: Bool = false
    @State var isShowingMFA3: Bool = false
    
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
                
                mfaGraphic
                    .opacity(isShowingMFAGraphic ? 1 : 0)
            }
            
            MFANavigationLink(image: Image(systemName: "text.bubble"), title: "SMS Text Message", description: "Send a your phone a text message containing the MFA code") {
                SMSEducationView()
            }
            .opacity(isShowingMFA1 ? 1 : 0)
            
            MFANavigationLink(image: Image(systemName: "lock.app.dashed"), title: "Authenticator App", description: "Have a rotating set of codes displayed on your phone inside an authenticator app") {
                Text("Setup Authenticator App")
            }
            .opacity(isShowingMFA2 ? 1 : 0)
            
            MFANavigationLink(image: Image(systemName: "person.badge.key"), title: "Passkeys", description: "Authenticate with an application or website through Passkeys and FaceID") {
                Text("Setup Passkeys")
            }
            .opacity(isShowingMFA3 ? 1 : 0)
        }
        .task {
            try? await Task.sleep(for: .seconds(2))
            withAnimation {
                isShowingMFAGraphic = true
            }
            try? await Task.sleep(for: .seconds(2))
            withAnimation {
                isShowingMFA1 = true
            }
            try? await Task.sleep(for: .milliseconds(750))
            withAnimation {
                isShowingMFA2 = true
            }
            try? await Task.sleep(for: .milliseconds(750))
            withAnimation {
                isShowingMFA3 = true
            }
        }
    }
    
    private var mfaGraphic: some View {
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
