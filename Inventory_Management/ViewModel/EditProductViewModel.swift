//
//  EditPackageViewModel.swift
//  NirvanaTour
//
//  Created by Yohanes  Ari on 06/11/24.
//

import SwiftUI
import FirebaseFirestore
import FirebaseStorage

@MainActor
final class EditProductViewModel: ObservableObject {
    @Published var name: String
    @Published var categories: String
    @Published var description: String
    @Published var stock: Int
    @Published var price: String
    @Published var existingImageUrls: [String]
    @Published var selectedImages: [UIImage]
    @Published var selectedSupplier: Supplier?
    @Published var suppliers: [Supplier] = []
    var imageDataArray: [Data]
    private let productId: String
    private let supplierId: String
    private let supplierName: String

    init(product: InventoryItem) {
        self.productId = product.id ?? ""
        self.name = product.name
        self.categories = product.category
        self.description = product.description
        self.stock = product.stock
        self.price = String(product.price)
        self.existingImageUrls = product.imageUrl ?? []
        self.selectedImages = []
        self.imageDataArray = []
        self.supplierId = product.supplierId
        self.supplierName = product.supplierName
        
        fetchSuppliers()
    }

    func fetchSuppliers() {
        let db = Firestore.firestore()
        db.collection("suppliers").addSnapshotListener { snapshot, error in
            if let error = error {
                print("Error fetching suppliers: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No supplier data found.")
                return
            }
            
            self.suppliers = documents.compactMap { doc -> Supplier? in
                let data = doc.data()
                
                guard let nama = data["nama"] as? String,
                      let alamat = data["alamat"] as? String,
                      let kontak = data["kontak"] as? String,
                      let latitude = data["latitude"] as? Double,
                      let longitude = data["longitude"] as? Double else {
                    print("Invalid data format for supplier: \(doc.documentID)")
                    return nil
                }
                
                let supplier = Supplier(
                    id: doc.documentID,
                    nama: nama,
                    alamat: alamat,
                    kontak: kontak,
                    latitude: latitude,
                    longitude: longitude
                )
                
                // Set selectedSupplier if this is the current supplier
                if doc.documentID == self.supplierId {
                    self.selectedSupplier = supplier
                }
                
                return supplier
            }
        }
    }

    func removeExistingImage(url: String) {
        existingImageUrls.removeAll { $0 == url }
    }

    func removeSelectedImage(image: UIImage) {
        selectedImages.removeAll { $0 == image }
    }

    func updateProduct(success: @escaping () -> (), failure: @escaping (Error) -> ()) {
        guard let supplier = selectedSupplier else {
            failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Please select a supplier"]))
            return
        }

        var updatedImageUrls = existingImageUrls
        let dispatchGroup = DispatchGroup()

        for imageData in imageDataArray {
            dispatchGroup.enter()
            let storageRef = Storage.storage().reference().child("images/\(UUID().uuidString).jpg")
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"

            storageRef.putData(imageData, metadata: metadata) { metadata, error in
                if let error = error {
                    failure(error)
                    dispatchGroup.leave()
                    return
                }

                storageRef.downloadURL { url, error in
                    if let error = error {
                        failure(error)
                    } else if let imageUrl = url?.absoluteString {
                        updatedImageUrls.append(imageUrl)
                    }
                    dispatchGroup.leave()
                }
            }
        }

        dispatchGroup.notify(queue: .main) {
            let productData: [String: Any] = [
                "name": self.name,
                "categories": self.categories,
                "description": self.description,
                "stock": self.stock,
                "price": Double(self.price) ?? 0,
                "imageUrl": updatedImageUrls,
                "supplierId": supplier.id,
                "supplierName": supplier.nama
            ]

            let db = Firestore.firestore()
            db.collection("inventory").document(self.productId).updateData(productData) { error in
                if let error = error {
                    failure(error)
                } else {
                    success()
                }
            }
        }
    }
}
