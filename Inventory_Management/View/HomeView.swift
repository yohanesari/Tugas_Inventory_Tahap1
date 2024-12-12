
//  HomeView.swift
//  Inventory_Management
//
//  Created by Yohanes  Ari on 26/11/24.
//

import SwiftUI

struct HomeView: View {
    @AppStorage("inventoryData") private var inventoryData: String = "[]"
    @State private var isEditing = false
    @State private var selectedItem: InventoryItem? = nil

    var items: [InventoryItem] {
        if let data = inventoryData.data(using: .utf8),
           let decodedItems = try? JSONDecoder().decode([InventoryItem].self, from: data) {
            return decodedItems
        }
        return []
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(items) { item in
                    NavigationLink(destination: DetailView(item: item)) {
                        HStack {
                            // Gambar
                            if let data = item.imageData,
                               let uiImage = UIImage(data: data) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 50)
                                    .clipped()
                                    .cornerRadius(5)
                            } else {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(width: 50, height: 50)
                                    .cornerRadius(5)
                            }
                            
                            // Detail Barang
                            VStack(alignment: .leading) {
                                Text(item.name)
                                    .font(.headline)
                                Text(item.description)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .lineLimit(2)
//                                Text(item.stock)
//                                    .font(.subheadline)
//                                    .foregroundColor(.gray)
//                                    .lineLimit(2)
                                Text("Rp \(item.price, specifier: "%.2f")")
                                    .font(.subheadline)
                                    .foregroundColor(.green)
                            }
                        }
                    }
                    .swipeActions(edge: .trailing) {
                        // Tombol Hapus
                        Button(role: .destructive) {
                            deleteItem(item)
                        } label: {
                            Label("Hapus", systemImage: "trash")
                        }
                        
                        // Tombol Edit
                        NavigationLink(destination: EditView(item: item) { updatedItem in
                            updateItem(updatedItem)
                        }) {
                            Label("Edit", systemImage: "pencil")
                        }
                        .tint(.blue)
                    }
                }
                    
            }
            .navigationTitle("Inventory")
            // Add Button with Gradient
            NavigationLink(destination: AddView()) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Tambah Barang")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.7)]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .foregroundColor(.white)
                .cornerRadius(12)
                .shadow(radius: 5)
                .padding()
            }
        }
    }

    func deleteItem(_ item: InventoryItem) {
        var currentItems = items
        currentItems.removeAll { $0.id == item.id }
        saveItems(currentItems)
    }

    func updateItem(_ updatedItem: InventoryItem) {
        var currentItems = items
        if let index = currentItems.firstIndex(where: { $0.id == updatedItem.id }) {
            currentItems[index] = updatedItem
        }
        saveItems(currentItems)
    }

    func saveItems(_ items: [InventoryItem]) {
        if let encodedData = try? JSONEncoder().encode(items) {
            inventoryData = String(data: encodedData, encoding: .utf8) ?? "[]"
        }
    }
}
