//
//  PasswordItemDetailView.swift
//  Lock
//
//  Created by Morris Richman on 12/1/24.
//

import SwiftUI
import CryptoKit

struct PasswordItemDetailView: View {
    @Bindable var item: Item
    @Environment(AES.self) var aes
    @Environment(\.colorScheme) var colorScheme
    @Namespace var namespace
    
    @State var isEditing: Bool = false
    @State var isShowingPassword: Bool = false
    @State var textPassword: String? = nil
    @State var isShowingMFAEducation = false
    
    var body: some View {
        ScrollView {
            VStack {
                GroupBox {
                    HStack {
                        Image(systemName: "globe")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30, height: 30)
                            .foregroundStyle(.white)
                            .frame(width: 50, height: 50)
                            .background(Color.gray.secondary)
                        
                        VStack(alignment: .leading) {
                            if !isEditing {
                                Text(item.name ?? item.website)
                                    .font(.title)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .matchedGeometryEffect(id: "name_text", in: namespace)
                            } else {
                                TextField("Name", text: optionalToRequiredStringBinding($item.name))
                                    .font(.title)
                                    .textFieldStyle(.emptyable(with: $item.name))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .matchedGeometryEffect(id: "name_text", in: namespace)
                            }
                        }
                        
                        Spacer()
                    }
                    
                    editableRowItem(withName: "User Name", binding: $item.userName)
                    passwordRow
                    editableRowItem(withName: "Website", binding: $item.website, isShowing: item.name?.isEmpty == false, valueTint: .accentColor)
                    mfaRow
                }
            }
            .frame(maxWidth: 800)
            .padding()
        }
        .onAppear(perform: {
            self.textPassword = item.readPassword(from: aes)
        })
        .onChange(of: item, {
            self.textPassword = item.readPassword(from: aes)
        })
        .animation(.default, value: isEditing)
        .toolbar {
            Button(!isEditing ? "Edit" : "Done") { isEditing.toggle() }
        }
    }
    
    func optionalToRequiredStringBinding(_ binding: Binding<String?>, defaultValue: String = "") -> Binding<String> {
        .init(get: { binding.wrappedValue ?? defaultValue }, set: { newValue in
            if newValue.isEmpty {
                binding.wrappedValue = nil
            } else {
                binding.wrappedValue = newValue
            }
        })
    }
    
    func editableRowItem(withName name: String, binding: Binding<String>, isShowing: Bool? = nil, valueTint: Color? = nil) -> some View {
        let binding: Binding<String?> = .init(get: { binding.wrappedValue }, set: { binding.wrappedValue = $0 ?? "" })
        
        return editableRowItem(withName: name, binding: binding, isShowing: isShowing, valueTint: valueTint)
    }
    
    @ViewBuilder
    func editableRowItem(withName name: String, binding: Binding<String?>, isShowing: Bool? = nil, valueTint: Color? = nil) -> some View {
        if let text = binding.wrappedValue, !text.isEmpty, (isShowing ?? true), !isEditing {
            Divider()
                .matchedGeometryEffect(id: "\(name)_divider", in: namespace)
            
            HStack {
                Text(name)
                    .matchedGeometryEffect(id: "\(name)_name", in: namespace)
                
                Spacer()
                
                Text(text)
                    .foregroundStyle(valueTint ?? .primary)
                    .matchedGeometryEffect(id: "\(name)_text", in: namespace)
            }
        } else if isEditing {
            Divider()
                .matchedGeometryEffect(id: "\(name)_divider", in: namespace)
            
            HStack {
                Text(name)
                    .matchedGeometryEffect(id: "\(name)_name", in: namespace)
                
                Spacer()
                
                TextField(name, text: optionalToRequiredStringBinding(binding))
                    .foregroundStyle(valueTint ?? .primary)
                    .multilineTextAlignment(.trailing)
                    .textFieldStyle(.emptyable(with: $item.userName))
                    .matchedGeometryEffect(id: "\(name)_text", in: namespace)
            }
        }
    }
    
    @ViewBuilder
    var passwordRow: some View {
        VStack {
            if let text = textPassword, !text.isEmpty, !isEditing {
                Divider()
                    .matchedGeometryEffect(id: "password_divider", in: namespace)
                
                HStack {
                    Text("Password")
                        .matchedGeometryEffect(id: "password_name", in: namespace)
                    
                    Spacer()
                    
                    Text(text)
                        .textSelection(.enabled)
                        .matchedGeometryEffect(id: "password_text", in: namespace)
                        .onTapGesture {
                            isShowingPassword.toggle()
                        }
                        .background(content: {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(!isShowingPassword ? .clear : Color(uiColor: .tertiarySystemBackground))
                                .opacity(!isShowingPassword ? 0 : 1)
                                .onTapGesture {
                                    isShowingPassword.toggle()
                                }
                                .scaleEffect(x: 1.2)
                        })
                        .overlay {
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(isShowingPassword ? .primary : Color(uiColor: .secondarySystemBackground), lineWidth: 2)
                                .shadow(color: .primary, radius: 2)
                                .overlay(content: {
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(isShowingPassword ? .clear : Color(uiColor: .secondarySystemBackground))
                                        .onTapGesture {
                                            isShowingPassword.toggle()
                                        }
                                })
                                .opacity(isShowingPassword ? 0 : 1)
                                .scaleEffect(x: 1.2)
                        }
                        .animation(.default, value: isShowingPassword)
                }
            } else if isEditing {
                Divider()
                    .matchedGeometryEffect(id: "password_divider", in: namespace)
                
                HStack {
                    Text("Password")
                        .matchedGeometryEffect(id: "password_name", in: namespace)
                    
                    Spacer()
                    
                    TextField("Password", text: optionalToRequiredStringBinding($textPassword))
                        .multilineTextAlignment(.trailing)
                        .textFieldStyle(.emptyable(with: $item.userName))
                        .matchedGeometryEffect(id: "password_text", in: namespace)
                        .onChange(of: textPassword) {
                            item.setPassword(textPassword, using: aes)
                        }
                }
            }
            
            PasswordsRequirementsView(
                password: optionalToRequiredStringBinding($textPassword),
                alignment: .trailing,
                requirementsTitleFont: .title3,
                requirementsTextFont: .footnote
            )
            .scaleEffect(y: isEditing ? 1 : 0)
            .frame(height: !isEditing ? 0 : nil)
            .opacity(isEditing ? 1 : 0)
            .allowsHitTesting(!isEditing)
        }
    }
    
    @ViewBuilder
    var mfaRow: some View {
        VStack {
            Divider()
                .matchedGeometryEffect(id: "mfa_divider", in: namespace)
            
            HStack {
                Text("Multi-Factor Authentication")
                    .matchedGeometryEffect(id: "mfa_name", in: namespace)
                
                if !isEditing {
                    Spacer()
                        .matchedGeometryEffect(id: "mfa_spacer", in: namespace)
                }
                
                Button("Learn More") { isShowingMFAEducation.toggle() }
                    .buttonStyle(.bordered)
                    .popover(isPresented: $isShowingMFAEducation) {
                        NavigationStack {
                            Setup2FAView(isAnimatedIntro: false)
                                .toolbar {
                                    Button {
                                        isShowingMFAEducation = false
                                    } label: {
                                        Label("Close", systemImage: "xmark.circle")
                                    }
                                }
                        }
                        .frame(width: 600, height: 800)
                        .padding(.horizontal)
                    }
                    .matchedGeometryEffect(id: "mfa_learn_more", in: namespace)
                    .background(alignment: .trailing) {
                        if !isEditing {
                            Button("Setup") {}
                                .buttonStyle(.borderedProminent)
                                .hidden()
                                .matchedGeometryEffect(id: "mfa_setup", in: namespace)
                        }
                    }
                
                if isEditing {
                    Spacer()
                        .matchedGeometryEffect(id: "mfa_spacer", in: namespace)
                    
                    Button("Setup") {}
                        .buttonStyle(.borderedProminent)
                        .matchedGeometryEffect(id: "mfa_setup", in: namespace)
                }
            }
        }
    }
    
    @State private(set) var timeUntilNewOtp: TimeInterval?
    
    @State private(set) var otpText = ""
    @State private var totpSecretText = UUID().uuidString
    func updateTotp() {
        let period = TimeInterval(30)
        let digits = 6
        guard let secret = totpSecretText.data(using: .utf8) else { return }
        var counter = UInt64(Date().timeIntervalSince1970 / period).bigEndian

        // Generate the key based on the counter.
        let key = SymmetricKey(data: Data(bytes: &counter, count: MemoryLayout.size(ofValue: counter)))
        let hash = HMAC<Insecure.SHA1>.authenticationCode(for: secret, using: key)

        var truncatedHash = hash.withUnsafeBytes { ptr -> UInt32 in
            let offset = ptr[hash.byteCount - 1] & 0x0f

            let truncatedHashPtr = ptr.baseAddress! + Int(offset)
            return truncatedHashPtr.bindMemory(to: UInt32.self, capacity: 1).pointee
        }

        truncatedHash = UInt32(bigEndian: truncatedHash)
        truncatedHash = truncatedHash & 0x7FFF_FFFF
        truncatedHash = truncatedHash % UInt32(pow(10, Float(digits)))

        let otpText = String(format: "%0*u", digits, truncatedHash)
        
        let timeElapsed = Date().timeIntervalSince1970.truncatingRemainder(dividingBy: period)
        self.timeUntilNewOtp = (period - timeElapsed)+1
        
        guard otpText != self.otpText else {
            return
        }
        self.otpText = otpText
    }
}
