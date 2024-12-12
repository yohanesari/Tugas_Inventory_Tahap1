//
//  EditView.swift
//  Inventory_Management
//
//  Created by Yohanes  Ari on 26/11/24.
//

import SwiftUI

import SwiftUI

struct EditView: View {
    @Environment(\.dismiss) var dismiss

    @State private var name: String
    @State private var description: String
    @State private var price: String
    @State private var category: String
    @State private var stock: String
    @State private var selectedImage: UIImage?
    @State private var isShowingImagePicker = false
    @State private var imageSourceType: UIImagePickerController.SourceType = .photoLibrary
    
    @State private var showValidationError = false
    @State private var validationErrorMessage = ""

    let item: InventoryItem
    let onSave: (InventoryItem) -> Void

    init(item: InventoryItem, onSave: @escaping (InventoryItem) -> Void) {
        self.item = item
        self.onSave = onSave
        _name = State(initialValue: item.name)
        _description = State(initialValue: item.description)
        _price = State(initialValue: String(format: "%.2f", item.price))
        _category = State(initialValue: item.category)
        _stock = State(initialValue: String(item.stock))
        if let imageData = item.imageData {
            _selectedImage = State(initialValue: UIImage(data: imageData))
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Image Section
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
                        
                        // Image Selection Buttons
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
                    
                    // Input Fields
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
                    
                    // Validation Error Message
                    if showValidationError {
                        Text(validationErrorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding()
                    }
                    
                    // Save Button with Gradient
                    Button(action: {
                        if validateInputs() {
                            saveChanges()
                            dismiss()
                        }
                    }) {
                        Text("Save Changes")
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
            .navigationTitle("Edit Product")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $isShowingImagePicker) {
                ImagePicker(selectedImage: $selectedImage, sourceType: imageSourceType)
            }
        }
    }
    
    func validateInputs() -> Bool {
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

    func saveChanges() {
        let updatedItem = InventoryItem(
            id: item.id,
            name: name,
            description: description,
            price: Double(price) ?? 0,
            category: category,
            stock: Int(stock) ?? 0,
            imageData: selectedImage?.jpegData(compressionQuality: 0.8)
        )
        onSave(updatedItem)
    }
}

