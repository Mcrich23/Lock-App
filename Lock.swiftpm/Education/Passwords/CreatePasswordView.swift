//
//  CreatePasswordView.swift
//  Pass
//
//  Created by Morris Richman on 11/17/24.
//

import SwiftUI

private enum PasswordStrength {
    case weak
    case ok
    case strong
    
    init?(from requirements: Double) {
        switch requirements {
        case 0..<4:
            self = .weak
        case 4..<6:
            self = .ok
        case 6:
            self = .strong
        default:
            return nil
        }
    }
}

struct CreatePasswordView: View {
    let nextAction: () -> Void
    @Environment(EductionNavigationController.self) var navigationController
    
    // MARK: Animated Setup Vars
    @State var showSetupText1 = false
    @State var showSetupText2 = false
    @State var isShowingMainView = false
    
    @State var password = ""
    @FocusState var isPasswordFieldFocused: Bool
    
    private var requirements: Array<Bool> {
        [
            password.count >= 15, // Minimum Length
            password.contains(where: { $0.isLowercase }), // One Number
            password.contains(where: { $0.isUppercase }), // One Number
            password.contains(where: { $0.isLetter }), // One Number
            password.contains(where: { $0.isNumber }), // One Number
            password.range(of: "[ !\"#$%&'()*+,-./:;<=>?@\\[\\\\\\]^_`{|}~]+", options: .regularExpression) != nil // One Special Character
        ]
    }
    
    private var requirementsBarValue: Double {
        let value = requirements.reduce(0) { $0 + ($1 ? 1 : 0) }
        
        guard value != requirements.count else {
            return Double(value)
        }
        
        return Double(value-1)
    }
    
    private var passwordStrength: PasswordStrength? {
        PasswordStrength(from: requirements.reduce(0) { $0 + ($1 ? 1 : 0) })
    }
    
    private var requirementsBarText: String {
        switch passwordStrength {
        case .weak:
            "Weak"
        case .ok:
            "Ok"
        case .strong:
            "Strong"
        default:
            "Unkown"
        }
    }
    
    private var requirementsBarColor: Color {
        switch passwordStrength {
        case .weak:
            Color.red
        case .ok:
            Color.yellow
        case .strong:
            Color.green
        default:
            Color.red
        }
    }
    
    private var topIcon: String {
        guard !password.isEmpty else {
            return "custom.lock.badge.plus"
        }
        
        switch passwordStrength {
        case .weak:
            return "custom.lock.badge.exclamationmark"
        case .ok:
            return "custom.lock.trianglebadge.exclamationmark"
        case .strong:
            return "custom.lock.badge.checkmark"
        default:
            return "custom.lock.badge.plus"
        }
    }
    
    var body: some View {
        VStack {
            if isShowingMainView {
                topIconView
            }
            ZStack {
                Text("Create a New Password")
                    .font(.title)
                    .opacity(isShowingMainView ? 1 : 0)
                VStack {
                    Text("Woah! That was an easy one.")
                        .opacity(showSetupText1 ? 1 : 0)
                    
                    Text("Let's make something a bit more secure.")
                        .opacity(showSetupText2 ? 1 : 0)
                }
                .font(.title3)
                .opacity(isShowingMainView ? 0 : 1)
            }
            .multilineTextAlignment(.center)
            .frame(alignment: .center)
            
            if !password.isEmpty && isShowingMainView {
                HStack {
                    ProgressView(value: requirementsBarValue, total: Double(requirements.count)) {
                        //                    Text("Valid")
                        EmptyView()
                    }
                    .frame(maxWidth: 400)
                    .progressViewStyle(.linear)
                    .tint(requirementsBarColor)
                    
                    Text(requirementsBarText)
                        .foregroundStyle(requirementsBarColor)
                }
            }
            
            if isShowingMainView {
                setPasswordView
            }
        }
        .padding()
        .task {
            try? await Task.sleep(for: .seconds(1))
            withAnimation {
                showSetupText1 = true
            }
            try? await Task.sleep(for: .seconds(2))
            withAnimation {
                showSetupText2 = true
            }
            try? await Task.sleep(for: .seconds(3))
            withAnimation(.default.speed(0.5)) {
                isShowingMainView = true
            }
        }
    }
    
    var topIconView: some View {
        Image(topIcon)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 100, height: 100)
            .symbolRenderingMode(password.isEmpty ? .monochrome : .multicolor)
            .foregroundStyle(Color.accentColor)
            .contentTransition(.symbolEffect(.replace.magic(fallback: .replace)))
    }
    
    var setPasswordView: some View {
        VStack {
            HStack {
                TextField("Enter your new password", text: $password.animation(.default))
                    .onSubmit(setPassword)
                    .focused($isPasswordFieldFocused)
                    .textFieldStyle(.custom)
                    .frame(maxWidth: 350)
                    .padding(.horizontal)
                    .textInputAutocapitalization(.never)
                    .padding(.trailing)
                
                Button("Enter", action: setPassword)
                    .buttonStyle(.borderedProminent)
                    .disabled(passwordStrength != .strong)
            }
            
            VStack(alignment: .leading) {
                Text("Should Include:")
                    .font(.title2)
                    .bold()
                VStack(alignment: .leading) {
                    Text("• At least 15 Characters")
                    Text("• At Least 1 Uppercase Letter")
                    Text("• At Least 1 Lowercase Letter")
                    Text("• At Least 1 Number")
                    Text("• At Least 1 Special Character")
                }
                .padding(.leading)
            }
            .frame(maxWidth: 500, alignment: .leading)
        }
    }
    
    func setPassword() {
        guard passwordStrength == .strong else { return }
        
        Task {
            isPasswordFieldFocused = false
            
            try? await Task.sleep(for: .milliseconds(500))
            nextAction()
        }
    }
}

#Preview {
    CreatePasswordView(nextAction: {})
}

extension String {
    static func &= (lhs: String, rhs: String) -> Bool {
        return lhs.range(of: rhs,options: .regularExpression) != nil
    }
}
