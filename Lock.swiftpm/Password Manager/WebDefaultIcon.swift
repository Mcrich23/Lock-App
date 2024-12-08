//
//  WebDefaultIcon.swift
//  Lock
//
//  Created by Morris Richman on 12/7/24.
//

import SwiftUI

struct PasswordIcon: View {
    let imageData: Data?
    
    var body: some View {
        if let imageData, let uiImage = UIImage(data: imageData) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50, height: 50)
//                .background(Color.gray.secondary)
        } else {
            WebDefaultIcon()
        }
    }
}

struct WebDefaultIcon: View {
    var body: some View {
        Image(systemName: "globe")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 30, height: 30)
            .foregroundStyle(.white)
            .frame(width: 50, height: 50)
            .background(Color.gray.secondary)
    }
}

#Preview {
    WebDefaultIcon()
}
