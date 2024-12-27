//
//  EditPackageView.swift
//  NirvanaTour
//
//  Created by Yohanes  Ari on 06/11/24.
//

import SwiftUI
import FirebaseFirestore
import FirebaseStorage

struct EditProductView: View {
    @StateObject private var viewModel: EditProductViewModel
    @Environment(\.dismiss) var dismiss
    @State private var imagePickerPresented = false
    @State private var showImagePickerOptions = false
    @State private var stockText: String = ""
    @State private var selectedSourceType: UIImagePickerController.SourceType = .photoLibrary
    
    init(viewModel: EditProductViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
        _stockText = State(initialValue: String(viewModel.stock))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                imageSelectionSection
                
                CustomTextFieldView(fieldBinding: $viewModel.name, fieldName: "Package Name")
                CustomTextFieldView(fieldBinding: $viewModel.categories, fieldName: "Category")
                CustomTextFieldView(fieldBinding: $viewModel.description, fieldName: "Description", isMultiline: true)
                CustomTextFieldView(fieldBinding: $viewModel.price, fieldName: "Price Package")
                CustomTextFieldView(fieldBinding: $stockText, fieldName: "Stock")
                    .onChange(of: stockText) { newValue in
                        viewModel.stock = Int(newValue) ?? 0
                    }
                
                Text("Choose Supplier")
                    .font(.subheadline)
                
                if !viewModel.suppliers.isEmpty {
                    Picker("Select Supplier", selection: $viewModel.selectedSupplier) {
                        ForEach(viewModel.suppliers, id: \.id) { supplier in
                            Text(supplier.nama).tag(supplier as Supplier?)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding()
                } else {
                    Text("Loading suppliers...")
                        .padding()
                }
            }
            .padding()
        }
        .navigationTitle("Edit Package")
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                saveButton
            }
        }
        .sheet(isPresented: $imagePickerPresented) {
            MultipleImagePicker(images: $viewModel.selectedImages,
                              imageDataArray: $viewModel.imageDataArray,
                              sourceType: selectedSourceType)
        }
        .actionSheet(isPresented: $showImagePickerOptions) {
            imagePickerActionSheet
        }
    }
    
    private var imageSelectionSection: some View {
        VStack(alignment: .leading) {
            Text("Product Images")
                .font(.headline)
                .padding(.bottom, 5)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    existingImagesView
                    newImagesView
                    addImageButton
                }
            }
        }
    }
    
    private var existingImagesView: some View {
        ForEach(viewModel.existingImageUrls, id: \.self) { imageUrl in
            ZStack(alignment: .topTrailing) {
                AsyncImage(url: URL(string: imageUrl)) { image in
                    image.resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                } placeholder: {
                    ProgressView()
                }
                
                Button(action: {
                    viewModel.removeExistingImage(url: imageUrl)
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                }
                .offset(x: 5, y: -5)
            }
        }
    }
    
    private var newImagesView: some View {
        ForEach(viewModel.selectedImages, id: \.self) { uiImage in
            ZStack(alignment: .topTrailing) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                
                Button(action: {
                    viewModel.removeSelectedImage(image: uiImage)
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                }
                .offset(x: 5, y: -5)
            }
        }
    }
    
    private var addImageButton: some View {
        Button(action: { showImagePickerOptions.toggle() }) {
            VStack {
                Image(systemName: "photo.on.rectangle.angled")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 100)
                Text("Tap to select images")
            }
        }
    }
    
    private var imagePickerActionSheet: ActionSheet {
        ActionSheet(
            title: Text("Select Image"),
            buttons: [
                .default(Text("Photo Library")) {
                    selectedSourceType = .photoLibrary
                    imagePickerPresented.toggle()
                },
                .default(Text("Camera")) {
                    selectedSourceType = .camera
                    imagePickerPresented.toggle()
                },
                .cancel()
            ]
        )
    }
    
    private var saveButton: some View {
        Button("Save Changes") {
            viewModel.updateProduct {
                print("Package updated successfully")
                dismiss()
            } failure: { error in
                print("Failed to update package:", error.localizedDescription)
            }
        }
    }
}
