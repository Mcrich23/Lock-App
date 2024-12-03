//
//  PasswordNavigationView.swift
//  Lock
//
//  Created by Morris Richman on 12/1/24.
//

import SwiftUI

struct PasswordNavigationView: View {
    @State var currentItem: Item?
    
    var body: some View {
        NavigationSplitView {
            PasswordListView()
                .navigationDestination(for: Item.self) { item in
                    PasswordItemDetailView(item: item)
                }
        } detail: {
            if let currentItem {
                PasswordItemDetailView(item: currentItem)
            } else {
                EmptyView()
            }
        }
    }
}

#Preview {
    PasswordNavigationView()
}
