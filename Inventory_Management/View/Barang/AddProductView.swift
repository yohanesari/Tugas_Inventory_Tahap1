//
//  UploadExploreView.swift
//  NirvanaTour
//
//  Created by Yohanes  Ari on 18/10/24.
//

import SwiftUI

struct AddProductView: View {
    @StateObject private var viewModel = AddProductViewModel()
    @State private var imagePickerPresented = false
    @State private var showImagePickerOptions = false
    @State private var selectedSourceType: UIImagePickerController.SourceType = .photoLibrary
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    imageSelectionSection
                    
                    CustomTextFieldView(fieldBinding: $viewModel.name, fieldName: "Product Name")
                    
                    CustomTextFieldView(fieldBinding: $viewModel.categories, fieldName: "Categories")
                    
                    CustomTextFieldView(fieldBinding: $viewModel.description, fieldName: "Description")
                    
                    CustomTextFieldView(fieldBinding: $viewModel.price, fieldName: "Price")
                    
                    CustomTextFieldView(fieldBinding: $viewModel.stockText, fieldName: "Stock")
                        .keyboardType(.numberPad)
                        .onChange(of: viewModel.stockText) { newValue in
                            viewModel.updateStock(from: newValue)
                        }
                    Text("Choose Supplier")
                        .font(.subheadline)
                    // Picker for selecting Supplier
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
            .navigationTitle("Upload Product")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    submitButton
                }
            }
        }
        .sheet(isPresented: $imagePickerPresented) {
            MultipleImagePicker(images: $viewModel.selectedImages, imageDataArray: $viewModel.imageDataArray, sourceType: selectedSourceType)
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
                    imageGridView
                    addImageButton
                }
            }
        }
    }
    
    private var imageGridView: some View {
        ForEach(viewModel.selectedImages, id: \.self) { uiImage in
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 10))
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
    
    private var submitButton: some View {
        Button("Submit") {
            viewModel.uploadPackage {
                print("Package uploaded successfully")
            } failure: { error in
                print("Failed to upload package:", error.localizedDescription)
            }
        }
    }
}


struct MultipleImagePicker: UIViewControllerRepresentable {
    @Binding var images: [UIImage]
    @Binding var imageDataArray: [Data]
    var sourceType: UIImagePickerController.SourceType

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: MultipleImagePicker

        init(parent: MultipleImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.images.append(uiImage)
                if let imageData = uiImage.jpegData(compressionQuality: 0.8) {
                    parent.imageDataArray.append(imageData)
                }
            }
            picker.dismiss(animated: true)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.allowsEditing = false
        picker.sourceType = sourceType
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}
