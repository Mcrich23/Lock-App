//
//  CustomTextFieldStyle.swift
//  Lock
//
//  Created by Morris Richman on 11/17/24.
//

import SwiftUI

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
            .scaleEffect(1.2)
    }
}

extension TextFieldStyle where Self == CustomTextFieldStyle {
    static var custom: CustomTextFieldStyle { get { CustomTextFieldStyle() } set {} }
}
