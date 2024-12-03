//
//  EmptyableTextFieldStyle.swift
//  Lock
//
//  Created by Morris Richman on 12/2/24.
//

import SwiftUI

struct EmptyableTextFieldStyle: @preconcurrency TextFieldStyle {
    @Binding var string: String?
    @Environment(\.multilineTextAlignment) var multilineTextAlignment
    
    @FocusState var isFocused: Bool
    
    @MainActor
    func _body(configuration: TextField<Self._Label>) -> some View {
        if multilineTextAlignment == .trailing {
            HStack(spacing: 2) {
                configuration
                    .focused($isFocused)
                
                if let string, !string.isEmpty, isFocused {
                    Button {
                        self.string = nil
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 15, height: 15)
                    }
                    .foregroundStyle(Color.secondary)
                }
            }
        } else {
            configuration
                .focused($isFocused)
                .overlay(alignment: .trailing) {
                    if let string, !string.isEmpty, isFocused {
                        Button {
                            self.string = nil
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        }
                        .foregroundStyle(Color.secondary)
                        .background(.regularMaterial)
                        .clipShape(.circle)
                        .scaleEffect(0.85)
                    }
                }
        }
    }
}

extension TextFieldStyle where Self == EmptyableTextFieldStyle {
    static func emptyable(with string: Binding<String?>) -> EmptyableTextFieldStyle {
        EmptyableTextFieldStyle(string: string)
    }
}
