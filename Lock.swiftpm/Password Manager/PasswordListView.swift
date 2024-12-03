//
//  PasswordListView.swift
//  Lock
//
//  Created by Morris Richman on 12/1/24.
//

import SwiftUI
import SwiftData

struct PasswordListView: View {
    @Query private var items: [Item]
    @Environment(\.modelContext) var modelContext
    
    var body: some View {
        List {
            ForEach(items) { item in
                PasswordListRowView(item: item)
            }
            .onDelete(perform: deleteItems)
        }
        .navigationTitle("Passwords")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: addItem) {
                    Image(systemName: "plus.circle")
                }
            }
        }
    }
    
    func addItem() {
        modelContext.insert(Item(website: "example.com"))
        try? modelContext.save()
    }
    
    func deleteItems(indexSet: IndexSet) {
        for index in indexSet {
            deleteItem(items[index])
        }
    }
    
    func deleteItem(_ item: Item) {
        modelContext.delete(item)
        try? modelContext.save()
    }
}

struct PasswordListRowView: View {
    let item: Item
    
    var body: some View {
        NavigationLink(value: item) {
            HStack {
                Image(systemName: "globe")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                    .foregroundStyle(.white)
                    .frame(width: 50, height: 50)
                    .background(Color.gray.secondary)
                
                VStack {
                    Text(item.name ?? item.website)
                        .font(.headline)
                    
                    if let name = item.name, !name.isEmpty {
                        Text(item.website)
                            .font(.subheadline)
                    }
                }
            }
        }
    }
}

#Preview {
    PasswordListView()
}
