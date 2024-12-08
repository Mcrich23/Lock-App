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
            NavigationStack {
                Setup2FAView()
            }
                .transition(.blurReplace)
        } else {
            MFAEducationIntroView(isShowingMainView: $isShowingMainView, isShowingMFA: isShowingMFA)
                .transition(.blurReplace)
        }
    }
}

private struct MFAEducationIntroView: View {
    @State var showSetupText1 = false
    @State var showSetupText2 = false
    @Binding var isShowingMainView: Bool
    let isShowingMFA: Bool
    
    var body: some View {
        VStack {
            Image(systemName: "lock.open.fill")
                .resizable()
                .frame(width: 75, height: 75)
                .foregroundStyle(Color.red)
            Text("Your Lock account is **still** vulnerable...")
                .opacity(showSetupText1 ? 1 : 0)
            Text("Lets Fix It")
                .opacity(showSetupText2 ? 1 : 0)
        }
        .padding()
        .onAppear(perform: {
            guard isShowingMFA else { return }
            runAnimation()
        })
        .onChange(of: isShowingMFA, { oldValue, newValue in
            guard newValue else { return }
            runAnimation()
        })
    }
    
    func runAnimation() {
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
    }
}

struct Setup2FAView: View {
    let timer = UpsideDownAccuteTriangle.defaultTimer
    @State var controller = Setup2FAController()
    @State var isShowingMFAGraphic: Bool
    @State var isShowingMFATextUnderGraphic: Bool
    @State var isShowingMFAText: Bool
    @State var isShowingMFA1: Bool
    @State var isShowingMFA2: Bool
    @State var isShowingMFA3: Bool
    
    init(isAnimatedIntro: Bool = true) {
        isShowingMFAGraphic = !isAnimatedIntro
        isShowingMFATextUnderGraphic = !isAnimatedIntro
        isShowingMFAText = !isAnimatedIntro
        isShowingMFA1 = !isAnimatedIntro
        isShowingMFA2 = !isAnimatedIntro
        isShowingMFA3 = !isAnimatedIntro
    }
    
    var body: some View {
        GeometryReader { geo in
            ScrollView {
                VStack {
                    Text("Multi-Factor Authentication")
                        .font(.title)
                        .bold()
                        .multilineTextAlignment(.center)
                    
                    VStack(alignment: .leading) {
                        Text("Multi-Factor Authentication (MFA) is a way to add an extra layer of security to your account. You create an additional step to prove your identity when logging in. This can be through SMS, Authenticator Apps, Passkeys, and More.")
                    }
                    .padding(.top, 1)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: 600, alignment: .leading)
                    
                    HStack {
                        mfaGraphic
                        Divider()
                            .padding()
                        mfaHackerGraphic
                    }
                    .opacity(isShowingMFAGraphic ? 1 : 0)
                    .frame(maxWidth: geo.size.width-100)
                    
                    VStack(alignment: .leading) {
                        Text("MFA is highly recommended, because if one layer becomes comprimised, your account is still safe from attackers.")
                    }
                    .padding(.top, 1)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: 600, alignment: .leading)
                    .opacity(isShowingMFATextUnderGraphic ? 1 : 0)
                    .padding(.bottom)
                    
                    VStack(alignment: .leading) {
                        Text("Setup MFA")
                            .font(.title2)
                            .bold()
                    }
                    .padding(.top, 1)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: 700, alignment: .leading)
                    .opacity(isShowingMFAText ? 1 : 0)
                    
                    MFANavigationLink(image: Image(systemName: "text.bubble"), title: "SMS Text Message", description: "Send a your phone a text message containing the MFA code", isCompleted: controller.completedSms) {
                        SMSEducationView()
                            .environment(controller)
                    }
                    .opacity(isShowingMFA1 ? 1 : 0)
                    
                    MFANavigationLink(image: Image(systemName: "lock.app.dashed"), title: "Authenticator App", description: "Use a time based one-time password (TOTP) to in an authenticator app to login", isCompleted: controller.completedTotp) {
                        TOTPEducationView()
                            .environment(controller)
                    }
                    .opacity(isShowingMFA2 ? 1 : 0)
                    
                    MFANavigationLink(image: Image(systemName: "person.badge.key"), title: "Passkeys", description: "Authenticate with an application or website through Passkeys and FaceID", isCompleted: controller.completedPasskeys) {
                        PasskeysEducationView()
                            .environment(controller)
                    }
                    .opacity(isShowingMFA3 ? 1 : 0)
                }
                .padding(.horizontal, 2)
                .padding(.vertical)
            }
        }
        .task {
            try? await Task.sleep(for: .seconds(2))
            withAnimation {
                isShowingMFAGraphic = true
            }
            try? await Task.sleep(for: .seconds(2))
            withAnimation {
                isShowingMFATextUnderGraphic = true
            }
            try? await Task.sleep(for: .seconds(2))
            withAnimation {
                isShowingMFAText = true
            }
            try? await Task.sleep(for: .milliseconds(750))
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
        .environment(controller)
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
            Image(systemName: "lock.open.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50, height: 50)
                .foregroundStyle(Color.green)
                .background(
                    Color(uiColor: .systemBackground)
                        .frame(width: 25, height: 40)
                        .clipShape(RoundedRectangle(cornerRadius: 25))
                        .offset(x: -5, y: 15)
                )
                .background(
                    Color(uiColor: .systemBackground)
                        .clipShape(Circle())
                        .frame(width: 25, height: 30)
                        .offset(x: 11, y: -10)
                )
                .offset(x: 5, y: 30)
        }
        .scaleEffect(0.7)
    }
    
    private var mfaHackerGraphic: some View {
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
                .foregroundStyle(Color.red)
                .background(Color(uiColor: .systemBackground))
                .offset(x: 20, y: -12)
        }
        .overlay(alignment: .bottom) {
            Image(systemName: "lock.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50, height: 50)
                .foregroundStyle(Color.primary)
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
    let isCompleted: Bool
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
                                .multilineTextAlignment(.leading)
                                .minimumScaleFactor(0.7)
                                .foregroundStyle(Color.primary)
                        }
                    }
                    
                    if isCompleted {
                        Spacer()
                        Image(systemName: "checkmark.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 25)
                            .foregroundColor(.green)
                    }
                }
            }
            .frame(maxWidth: 700, alignment: .leading)
        }
        .matchedTransitionSource(id: "auth", in: namespace)
    }
}

#Preview("MFAEductionView") {
    MFAEductionView(isShowingMFA: true)
}
#Preview("Setup2FAView") {
    Setup2FAView()
}
#Preview("MFAEducationIntroView") {
    MFAEducationIntroView(isShowingMainView: .constant(false), isShowingMFA: true)
}
