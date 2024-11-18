//
//  CreatePasswordView.swift
//  Pass
//
//  Created by Morris Richman on 11/17/24.
//

import SwiftUI

struct CreatePasswordView: View {
    @State var showSetupText1 = false
    @State var showSetupText2 = false
    @State var isShowingMainView = false
    
    @Namespace var mainNamespace
    
    @State var password = ""
    
    private var requirements: Array<Bool> {
        [
            password.count >= 7, // Minimum Length
            password.contains(where: { $0.isNumber }), // One Number
            password.range(of: "[ !\"#$%&'()*+,-./:;<=>?@\\[\\\\\\]^_`{|}~]+", options: .regularExpression) != nil // One Special Character
        ]
    }
    
    private var requirementsBarValue: Double {
        requirements.reduce(0) { $0 + ($1 ? 1 : 0) }
    }
    
    private var requirementsBarText: String {
        switch requirementsBarValue {
        case 0, 1:
            "Weak"
        case 2:
            "Ok"
        case 3:
            "Strong"
        default:
            "Unkown"
        }
    }
    
    private var requirementsBarColor: Color {
        switch requirementsBarValue {
        case 0, 1:
            Color.red
        case 2:
            Color.yellow
        case 3:
            Color.green
        default:
            Color.red
        }
    }
    
    private var topIcon: String {
        guard !password.isEmpty else {
            return "custom.lock.badge.plus"
        }
        
        switch requirementsBarValue {
        case 0, 1:
            return "custom.lock.badge.exclamationmark"
        case 2:
            return "custom.lock.trianglebadge.exclamationmark"
        case 3:
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
                    .textFieldStyle(.custom)
                    .frame(maxWidth: 350)
                    .padding(.horizontal)
                    .textInputAutocapitalization(.never)
                    .padding(.trailing)
                
                Button("Enter", action: {})
                    .buttonStyle(.borderedProminent)
                    .disabled(password.isEmpty)
            }
            
            VStack(alignment: .leading) {
                Text("Should Include:")
                    .font(.title2)
                    .bold()
                VStack(alignment: .leading) {
                    Text("• 7 or More Characters")
                    Text("• At Least 1 Number")
                    Text("• At Least 1 Special Character")
                }
                .padding(.leading)
            }
            .frame(maxWidth: 500, alignment: .leading)
        }
    }
}

#Preview {
    CreatePasswordView()
}

extension String {
    static func &= (lhs: String, rhs: String) -> Bool {
        return lhs.range(of: rhs,options: .regularExpression) != nil
    }
}
