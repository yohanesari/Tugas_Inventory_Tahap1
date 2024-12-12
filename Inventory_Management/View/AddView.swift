//
//  AddView.swift
//  Inventory_Management
//
//  Created by Yohanes  Ari on 26/11/24.
//

import SwiftUI

struct AddView: View {
    @Environment(\.dismiss) var dismiss

    @State private var name: String = ""
    @State private var description: String = ""
    @State private var price: String = ""
    @State private var category: String = ""
    @State private var stock: String = "0"
    @State private var selectedImage: UIImage? = nil
    @State private var isShowingImagePicker = false
    @State private var imageSourceType: UIImagePickerController.SourceType = .photoLibrary
    
    @State private var showValidationError = false
    @State private var validationErrorMessage = ""

    @AppStorage("inventoryData") private var inventoryData: String = "[]"

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    VStack {
                        if let image = selectedImage {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 250)
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                )
                                .shadow(radius: 5)
                        } else {
                            ZStack {
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(LinearGradient(
                                        gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.blue.opacity(0.2)]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    ))
                                    .shadow(radius: 5)
                                
                                VStack {
                                    Image(systemName: "camera.fill")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 50, height: 50)
                                        .foregroundColor(.blue.opacity(0.5))
                                    
                                    Text("Add Product Photo")
                                        .foregroundColor(.blue.opacity(0.7))
                                        .fontWeight(.semibold)
                                }
                            }
                            .frame(height: 250)
                        }
                        
                        HStack(spacing: 15) {
                            Button(action: {
                                imageSourceType = .camera
                                isShowingImagePicker = true
                            }) {
                                Label("Take Photo", systemImage: "camera")
                                    .frame(maxWidth: .infinity)
                                    .padding(10)
                                    .background(Color.blue.opacity(0.1))
                                    .foregroundColor(.blue)
                                    .cornerRadius(10)
                            }
                            
                            Button(action: {
                                imageSourceType = .photoLibrary
                                isShowingImagePicker = true
                            }) {
                                Label("Choose from Gallery", systemImage: "photo.on.rectangle")
                                    .frame(maxWidth: .infinity)
                                    .padding(10)
                                    .background(Color.green.opacity(0.1))
                                    .foregroundColor(.green)
                                    .cornerRadius(10)
                            }
                        }
                        .padding(.top, 10)
                    }
                    
                    VStack(spacing: 15) {
                        CustomTextField(
                            title: "Product Name",
                            systemImage: "tag", text: $name
                        )
                        
                        CustomTextField(
                            title: "Description",
                            systemImage: "text.alignleft", text: $description
                        )
                        
                        CustomTextField(
                            title: "Price",
                            systemImage: "dollarsign.circle", keyboardType: .decimalPad, text: $price
                        )
                        
                        CustomTextField(
                            title: "Category",
                            systemImage: "folder", text: $category
                        )
                        
                        CustomTextField(
                            title: "Stock Quantity",
                            systemImage: "cube.box", keyboardType: .numberPad, text: $stock
                        )
                    }
                    
                    if showValidationError {
                        Text(validationErrorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding()
                    }
                    
                    Button(action: {
                        if validateInputs() {
                            saveItem()
                            dismiss()
                        }
                    }) {
                        Text("Save Item")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.7)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .shadow(radius: 5)
                    }
                    .padding(.top)
                }
                .padding()
            }
            .navigationTitle("Add New Product")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $isShowingImagePicker) {
                ImagePicker(selectedImage: $selectedImage, sourceType: imageSourceType)
            }
        }
    }
    
    func validateInputs() -> Bool {
        // Basic validation
        if name.isEmpty {
            validationErrorMessage = "Product name is required"
            showValidationError = true
            return false
        }
        
        if let priceValue = Double(price), priceValue <= 0 {
            validationErrorMessage = "Price must be greater than zero"
            showValidationError = true
            return false
        }
        
        if let stockValue = Int(stock), stockValue < 0 {
            validationErrorMessage = "Stock cannot be negative"
            showValidationError = true
            return false
        }
        
        showValidationError = false
        return true
    }

    func saveItem() {
        let newItem = InventoryItem(
            name: name,
            description: description,
            price: Double(price) ?? 0,
            category: category,
            stock: Int(stock) ?? 0, // Convert string to int
            imageData: selectedImage?.jpegData(compressionQuality: 0.8)
        )
        
        var items = getSavedItems()
        items.append(newItem)
        
        if let encodedData = try? JSONEncoder().encode(items) {
            inventoryData = String(data: encodedData, encoding: .utf8) ?? "[]"
        }
    }
    
    func getSavedItems() -> [InventoryItem] {
        if let data = inventoryData.data(using: .utf8),
           let items = try? JSONDecoder().decode([InventoryItem].self, from: data) {
            return items
        }
        return []
    }
}

struct CustomTextField: View {
    let title: String
    var systemImage: String
    var keyboardType: UIKeyboardType = .default
    
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: systemImage)
                .foregroundColor(.blue.opacity(0.6))
            
            TextField(title, text: $text)
                .keyboardType(keyboardType)
                .autocorrectionDisabled()
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

#Preview {
    AddView()
}
