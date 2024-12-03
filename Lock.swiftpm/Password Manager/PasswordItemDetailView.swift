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
    @Environment(\.modelContext) var modelContext
    @Namespace var namespace
    
    @State var isEditing: Bool = false
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
                            Text(item.name ?? item.website)
                                .font(.title)
                        }
                        
                        Spacer()
                    }
                    
                    editableRowItem(withName: "User Name", binding: $item.userName)
                    editableRowItem(withName: "Password", binding: $textPassword)
                        .onChange(of: textPassword) {
                            item.setPassword(textPassword, using: aes)
                        }
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
                
                TextField(name, text: Binding(get: { binding.wrappedValue ?? "" }, set: { binding.wrappedValue = $0 }))
                    .multilineTextAlignment(.trailing)
                    .textFieldStyle(.emptyable(with: $item.userName))
                    .matchedGeometryEffect(id: "\(name)_text", in: namespace)
            }
        }
    }
}
