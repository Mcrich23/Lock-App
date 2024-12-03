//
//  PasswordsRequirementsView.swift
//  Lock
//
//  Created by Morris Richman on 11/28/24.
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

struct PasswordsRequirementsView: View {
    @Binding var password: String
    let alignment: Alignment
    let requirementsTitleFont: Font
    let requirementsTextFont: Font
    
    init(password: Binding<String>, alignment: Alignment = .leading, requirementsTitleFont: Font = .title2, requirementsTextFont: Font = .body) {
        self._password = password
        self.alignment = alignment
        self.requirementsTitleFont = requirementsTitleFont
        self.requirementsTextFont = requirementsTextFont
    }
    
    @FocusState var isPasswordFieldFocused: Bool
    
    static func requirements(for password: String) -> Array<Bool> {
        [
            password.count >= 15, // Minimum Length
            password.contains(where: { $0.isLowercase }), // One Number
            password.contains(where: { $0.isUppercase }), // One Number
            password.contains(where: { $0.isLetter }), // One Number
            password.contains(where: { $0.isNumber }), // One Number
            password.range(of: "[ !\"#$%&'()*+,-./:;<=>?@\\[\\\\\\]^_`{|}~]+", options: .regularExpression) != nil // One Special Character
        ]
    }
    
    private var requirements: Array<Bool> { Self.requirements(for: password) }
    
    private var requirementsBarValue: Double {
        let value = requirements.reduce(0) { $0 + ($1 ? 1 : 0) }
        
        guard value != requirements.count, value > 0 else {
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
    
    private var textAlignment: TextAlignment {
        switch alignment.horizontal {
        case .leading, .listRowSeparatorLeading: .leading
        case .center: .center
            case .trailing, .listRowSeparatorTrailing: .trailing
        default:
                .leading
        }
    }
    
    var body: some View {
        VStack(alignment: alignment.horizontal) {
            HStack {
                if alignment.horizontal == .leading {
                    Text(requirementsBarText)
                        .foregroundStyle(requirementsBarColor)
                        .frame(minWidth: 50)
                }
                
                ProgressView(value: requirementsBarValue, total: Double(requirements.count)) {
                    //                    Text("Valid")
                    EmptyView()
                }
                .progressViewStyle(.linear)
                .tint(requirementsBarColor)
                
                if alignment.horizontal != .leading {
                    Text(requirementsBarText)
                        .foregroundStyle(requirementsBarColor)
                        .frame(minWidth: 50)
                }
            }
            setPasswordView
        }
        .animation(.default, value: password)
        .frame(maxWidth: .infinity, alignment: alignment)
        .multilineTextAlignment(textAlignment)
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
            VStack(alignment: alignment.horizontal) {
                Text("Should Include:")
                    .font(requirementsTitleFont)
                    .bold()
                VStack(alignment: alignment.horizontal) {
                    Text("• At least 15 Characters")
                    Text("• At Least 1 Uppercase Letter")
                    Text("• At Least 1 Lowercase Letter")
                    Text("• At Least 1 Number")
                    Text("• At Least 1 Special Character")
                }
                .font(requirementsTextFont)
                .padding(.leading)
            }
            .frame(maxWidth: 500, alignment: alignment)
        }
    }
}

#Preview {
    PasswordsRequirementsView(password: .constant(""))
}

