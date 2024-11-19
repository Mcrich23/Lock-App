//
//  NotificationAlertView.swift
//  Lock
//
//  Created by Morris Richman on 11/18/24.
//

import SwiftUI

struct NotificationAlertView: View {
    let title: String
    let subtitle: String
    let time: String
    let userInterfaceIdiom = UIDevice.current.userInterfaceIdiom
    
    var body: some View {
        HStack {
            Image(.messagesAppIcon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 50)
                .padding(.trailing, 3)
            VStack {
                HStack {
                    Text(title)
                        .bold()
                        .font(.headline)
                    Spacer()
                    Text(time)
                        .font(.subheadline)
                        .foregroundStyle(Color.secondary)
                }
                HStack {
                    Text(subtitle)
                    Spacer()
                }
            }
        }
        .frame(maxWidth: 500)
        .padding()
        .padding(.trailing, 3)
        .background(Color(uiColor: .secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 25))
    }
}
