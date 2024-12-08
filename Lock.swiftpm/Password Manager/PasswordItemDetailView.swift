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
    @Environment(\.openURL) var openURL
    @Namespace var namespace
    
    @State var isEditing: Bool = false
    @State var isShowingPassword: Bool = false
    @State var textPassword: String? = nil
    @State var isShowingMFAEducation = false
    let timer = Timer.publish(every: 0.001, on: .main, in: .common).autoconnect()
    
    var websiteURL: URL? {
        if let webUrl = URL(string: item.website), webUrl.scheme == nil, let url = URL(string: "https://\(item.website)") {
            return url
        } else if let url = URL(string: item.website) {
            return url
        }
        
        return nil
    }
    
    var body: some View {
        ScrollView {
            GeometryReader { geo in
                VStack {
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
                    
                    Group {
                        editableRowItem(withName: "User Name", binding: $item.userName)
                        passwordRow
                        
                        if isEditing {
                            editableRowItem(withName: "Website", binding: $item.website, isShowing: item.name?.isEmpty == false, valueTint: .accentColor)
                        } else {
                            editableRowItem(withName: "Website", binding: $item.website, isShowing: item.name?.isEmpty == false, valueTint: .accentColor)
                                .onTapGesture {
                                    if let websiteURL {
                                        openURL(websiteURL)
                                    }
                                }
                                .contextMenu {
                                    if let websiteURL {
                                        ShareLink(item: websiteURL)
                                        Link(destination: websiteURL) {
                                            Label("Open in Safari", systemImage: "safari")
                                        }
                                    }
                                }
                        }
                        
                        mfaRow(width: geo.size.width)
                    }
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                }
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(uiColor: .secondarySystemBackground))
                }
            }
            .frame(maxWidth: 800)
            .padding()
        }
        .onReceive(timer, perform: { _ in
            updateTotp()
        })
        .onAppear(perform: {
            self.textPassword = item.readPassword(from: aes)
            self.totpSecretText = item.readTotpSecret(from: aes)?.replacingOccurrences(of: "\n", with: "")
        })
        .onChange(of: item, {
            self.textPassword = item.readPassword(from: aes)
            self.totpSecretText = item.readTotpSecret(from: aes)
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
                                .scaleEffect(x: 1.05)
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
                                .scaleEffect(x: 1.05)
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
    var mfaLearnMoreButton: some View {
        Button("Learn More") { isShowingMFAEducation.toggle() }
            .buttonStyle(.bordered)
            .popover(isPresented: $isShowingMFAEducation) {
                NavigationStack {
                    Setup2FAView(isAnimatedIntro: false)
                        .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .phone ? 0 : nil)
                        .toolbar {
                            Button {
                                isShowingMFAEducation = false
                            } label: {
                                Label("Close", systemImage: "xmark.circle")
                            }
                        }
                }
                .frame(width: UIDevice.current.userInterfaceIdiom == .phone ? nil : 600, height: UIDevice.current.userInterfaceIdiom == .phone ? nil : 600, alignment: .top)
            }
            .matchedGeometryEffect(id: "mfa_learn_more", in: namespace)
            .background(alignment: .trailing) {
                if !isEditing && otpText == nil {
                    Button("Setup") {}
                        .buttonStyle(.borderedProminent)
                        .hidden()
                        .matchedGeometryEffect(id: "mfa_setup", in: namespace)
                }
            }
    }
    
    @ViewBuilder
    var mfaSetupResetButton: some View {
        if isEditing && !isShowingSetTotpSecret {
            if otpText == nil {
                Button("Setup") { isShowingSetTotpSecret.toggle() }
                    .buttonStyle(.borderedProminent)
                    .matchedGeometryEffect(id: "mfa_setup", in: namespace)
            } else {
                Button("Reset", action: resetTotp)
                    .buttonStyle(.borderedProminent)
                    .matchedGeometryEffect(id: "mfa_setup", in: namespace)
                    .padding(.leading, 15)
            }
        }
    }
    
    @ViewBuilder
    func mfaRow(width: CGFloat) -> some View {
        let hasTwoRows = width <= 375
        
        VStack {
            Divider()
                .matchedGeometryEffect(id: "mfa_divider", in: namespace)
            
            HStack {
                Text("Multi-Factor Authentication\(otpText != nil && hasTwoRows ? ": " : "")")
                    .matchedGeometryEffect(id: "mfa_name", in: namespace)
                
                if !isEditing && otpText == nil {
                    Spacer()
                        .matchedGeometryEffect(id: "mfa_spacer", in: namespace)
                }
                
                if !hasTwoRows {
                    mfaLearnMoreButton
                }
                
                if isEditing || otpText != nil {
                    Spacer()
                        .matchedGeometryEffect(id: "mfa_spacer", in: namespace)
                }
                
                if let otpText {
                    HStack(spacing: hasTwoRows ? 10 : 20) {
                        Text(otpText)
                            .contextMenu {
                                Button(action: {
                                    UIPasteboard.general.string = otpText
                                }) {
                                    Label("Copy to clipboard", systemImage: "doc.on.doc")
                                }
                             }
                        
                        if let time = timeUntilNewOtp {
                            CircleCountdownView(progress: 1-((time-1)/30))
                                .frame(width: 40, height: 40)
                                .overlay {
                                    Text("\(30-Int(time))")
                                }
                        }
                    }
                    .background(alignment: .trailing) {
                        if !isEditing {
                            Button("Reset", action: resetTotp)
                                .buttonStyle(.borderedProminent)
                                .hidden()
                                .matchedGeometryEffect(id: "mfa_setup", in: namespace)
                        }
                    }
                }
                
                if !hasTwoRows {
                    mfaSetupResetButton
                }
            }
            
            if hasTwoRows {
                HStack {
                    mfaLearnMoreButton
                    
                    Spacer()
                    
                    if isEditing && !isShowingSetTotpSecret {
                        mfaSetupResetButton
                    }
                }
            }
            
            if isEditing && isShowingSetTotpSecret {
                DataScannerRepresentable(shouldStartScanning: .constant(true), scannedText: $scannerTotpSecretText, dataToScanFor: [.barcode()])
                    .frame(width: 300, height: 300)
                    .onChange(of: scannerTotpSecretText) {
                        guard !scannerTotpSecretText.isEmpty else { return }
                        setupTotp()
                    }
                
                HStack {
                    TextField("Enter Secret", text: $enteredTotpSecretText)
                        .textFieldStyle(.roundedBorder)
                        .focused($isTotpSecretEntryFocused)
                        .onSubmit(setupTotp)
                    
                    Button("Setup", action: setupTotp)
                    .buttonStyle(.borderedProminent)
                    .matchedGeometryEffect(id: "mfa_setup", in: namespace)
                }
            }
        }
        .animation(.default, value: isShowingSetTotpSecret)
    }
    
    // MARK: TOTP
    @State private(set) var timeUntilNewOtp: TimeInterval?
    
    @State private(set) var otpText: String?
    @State private var isShowingSetTotpSecret: Bool = false
    @State private var totpSecretText: String?
    @State private var enteredTotpSecretText: String = ""
    @State private var scannerTotpSecretText: String = ""
    @FocusState private var isTotpSecretEntryFocused
    
    func setupTotp() {
        let scannerTotpSecretQuery: [URLQueryItem] = URL(string: scannerTotpSecretText)?.query(percentEncoded: false)?.split(separator: "&").compactMap { str in
            let split = str.split(separator: "=")
            guard split.count == 2 else { return nil }
            return URLQueryItem(name: String(split[0]), value: String(split[1]))
        } ?? []
        
        let qrSecret = scannerTotpSecretQuery.first(where: { $0.name == "secret" })?.value ?? scannerTotpSecretText
        
        let newTotpSecretText = qrSecret.isEmpty ? enteredTotpSecretText : qrSecret
        
        withAnimation {
            isTotpSecretEntryFocused = false
            isShowingSetTotpSecret = false
            totpSecretText = newTotpSecretText
        }
        item.setTotpSecret(newTotpSecretText, using: aes)
        print("set secret: \(newTotpSecretText)")
        let secret = item.readTotpSecret(from: aes)
        print("read secret: \(secret)")
    }
    
    func resetTotp() {
        withAnimation {
            totpSecretText = nil
            scannerTotpSecretText = ""
            enteredTotpSecretText = ""
            otpText = nil
        }
        item.setTotpSecret(nil, using: aes)
    }
    
    func updateTotp() {
        guard let totpSecretText else { return }
        
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
