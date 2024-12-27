//
//  HelperViews.swift
//  NirvanaTour
//
//  Created by Yohanes  Ari on 21/10/24.
//

import SwiftUI

struct CustomTextFieldView: View {
    @Binding var fieldBinding: String
    let fieldName: String
    let isMultiline: Bool
    
    init(fieldBinding: Binding<String>, fieldName: String, isMultiline: Bool = false) {
        self._fieldBinding = fieldBinding
        self.fieldName = fieldName
        self.isMultiline = isMultiline
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(fieldName)
            if isMultiline {
                TextEditor(text: $fieldBinding)
                    .frame(height: 100)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))
            } else {
                TextField(fieldName, text: $fieldBinding)
                    .padding(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))
            }
        }
    }
}

struct MultipleSelectionRow: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                if isSelected {
                    Spacer()
                    Image(systemName: "checkmark")
                }
            }
            .padding()
        }
        .foregroundColor(isSelected ? .blue : .primary)
    }
}

struct SUImagePickerView: UIViewControllerRepresentable {
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @Binding var image: Image?
    @Binding var isPresented: Bool
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(image: $image, isPresented: $isPresented)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        @Binding var image: Image?
        @Binding var isPresented: Bool
        
        init(image: Binding<Image?>, isPresented: Binding<Bool>) {
            _image = image
            _isPresented = isPresented
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                image = Image(uiImage: uiImage)  // Konversi UIImage ke SwiftUI Image
            }
            isPresented = false
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            isPresented = false
        }
    }
}
