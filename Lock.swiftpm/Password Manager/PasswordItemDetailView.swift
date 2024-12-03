//
//  PasswordItemDetailView.swift
//  Lock
//
//  Created by Morris Richman on 12/1/24.
//

import SwiftUI

struct PasswordItemDetailView: View {
    @Bindable var item: Item
    @Namespace var namespace
    
    @State var isEditing: Bool = false
    
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
                    
                    if let userName = item.userName, !isEditing {
                        Divider()
                        
                        HStack {
                            Text("User Name")
                            
                            Spacer()
                            
                            Text(userName)
                                .multilineTextAlignment(.trailing)
                                .matchedGeometryEffect(id: "username_text", in: namespace)
                        }
                    } else if isEditing {
                        Divider()
                        
                        HStack {
                            Text("User Name")
                            
                            Spacer()
                            
                            TextField("UserName", text: Binding(get: { item.userName ?? "" }, set: { item.userName = $0 }))
                                .multilineTextAlignment(.trailing)
                                .textFieldStyle(.emptyable(with: $item.userName))
                                .matchedGeometryEffect(id: "username_text", in: namespace)
                        }
                    }
                    
                    if let name = item.name, !name.isEmpty, !isEditing {
                        Divider()
                        
                        HStack {
                            Text("Website")
                            
                            Spacer()
                            
                            Text(item.website)
                                .matchedGeometryEffect(id: "website_text", in: namespace)
                        }
                    } else if isEditing {
                        Divider()
                        
                        HStack {
                            Text("Website")
                            
                            Spacer()
                            
                            TextField("Website", text: $item.website)
                                .multilineTextAlignment(.trailing)
                                .textFieldStyle(.emptyable(with: $item.userName))
                                .matchedGeometryEffect(id: "website_text", in: namespace)
                        }
                    }
                }
            }
            .frame(maxWidth: 800)
            .padding()
        }
        .animation(.default, value: isEditing)
        .toolbar {
            Button(!isEditing ? "Edit" : "Done") { isEditing.toggle() }
        }
    }
}
