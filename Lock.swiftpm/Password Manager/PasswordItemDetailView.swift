//
//  PasswordItemDetailView.swift
//  Lock
//
//  Created by Morris Richman on 12/1/24.
//

import SwiftUI

struct PasswordItemDetailView: View {
    @Bindable var item: Item
    @Environment(AES.self) var aes
    @Environment(\.colorScheme) var colorScheme
    @Namespace var namespace
    
    @State var isEditing: Bool = false
    @State var isShowingPassword: Bool = false
    @State var textPassword: String? = nil
    
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
                    editableRowItem(withName: "Website", binding: $item.website, isShowing: item.name?.isEmpty == false)
                }
            }
            .frame(maxWidth: 800)
            .padding()
        }
        .onAppear(perform: {
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
    
    func editableRowItem(withName name: String, binding: Binding<String>, isShowing: Bool? = nil) -> some View {
        let binding: Binding<String?> = .init(get: { binding.wrappedValue }, set: { binding.wrappedValue = $0 ?? "" })
        
        return editableRowItem(withName: name, binding: binding, isShowing: isShowing)
    }
    
    @ViewBuilder
    func editableRowItem(withName name: String, binding: Binding<String?>, isShowing: Bool? = nil) -> some View {
        if let text = binding.wrappedValue, !text.isEmpty, (isShowing ?? true), !isEditing {
            Divider()
            
            HStack {
                Text(name)
                
                Spacer()
                
                Text(text)
                    .matchedGeometryEffect(id: "\(name)_text", in: namespace)
            }
        } else if isEditing {
            Divider()
            
            HStack {
                Text(name)
                
                Spacer()
                
                TextField(name, text: optionalToRequiredStringBinding(binding))
                    .multilineTextAlignment(.trailing)
                    .textFieldStyle(.emptyable(with: $item.userName))
                    .matchedGeometryEffect(id: "\(name)_text", in: namespace)
            }
        }
    }
    
    @ViewBuilder
    var passwordRow: some View {
        if let text = textPassword, !text.isEmpty, !isEditing {
            Divider()
            
            HStack {
                Text("Password")
                
                Spacer()
                
//                Text(isShowingPassword ? text : "**************")
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
            
            HStack {
                Text("Password")
                
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
    }
}
