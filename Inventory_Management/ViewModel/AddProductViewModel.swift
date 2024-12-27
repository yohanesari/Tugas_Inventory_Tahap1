//
//  UploadPackageViewModel.swift
//  NirvanaTour
//
//  Created by Yohanes  Ari on 21/10/24.
//

import SwiftUI
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth // Tambahkan FirebaseAuth untuk mengambil userId

@MainActor
final class AddProductViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var categories: String = ""
    @Published var description: String = ""
    @Published var stock: Int = 0
    @Published var stockText: String = ""
    @Published var price: String = ""
    @Published var selectedImages: [UIImage] = []
    @Published var selectedSupplier: Supplier?
    @Published var suppliers: [Supplier] = []
    var imageDataArray: [Data] = []
    
    init() {
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
                    
                    // Extract fields with default values to handle missing data
                    guard let nama = data["nama"] as? String,
                          let alamat = data["alamat"] as? String,
                          let kontak = data["kontak"] as? String,
                          let latitude = data["latitude"] as? Double,
                          let longitude = data["longitude"] as? Double else {
                        print("Invalid data format for supplier: \(doc.documentID)")
                        return nil
                    }
                    
                    return Supplier(
                        id: doc.documentID,
                        nama: nama,
                        alamat: alamat,
                        kontak: kontak,
                        latitude: latitude,
                        longitude: longitude
                    )
                }
            }
        }

        func resetFields() {
            name = ""
            categories = ""
            description = ""
            stock = 0
            stockText = ""
            price = ""
            selectedImages = []
            imageDataArray = []
            selectedSupplier = nil
        }


    func uploadPackage(success: @escaping () -> (), failure: @escaping (Error) -> ()) {
        guard let currentUser = Auth.auth().currentUser else {
            failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not logged in"]))
            return
        }
        
        guard let supplier = selectedSupplier else {
            failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Please select a supplier"]))
            return
        }

        guard !imageDataArray.isEmpty else {
            failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Images data is missing"]))
            return
        }

        var uploadedImageUrls: [String] = []
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
                        uploadedImageUrls.append(imageUrl)
                    }
                    dispatchGroup.leave()
                }
            }
        }

        dispatchGroup.notify(queue: .main) {
            let packageData: [String: Any] = [
                "name": self.name,
                "categories": self.categories,
                "description": self.description,
                "stock": self.stock,
                "price": Double(self.price) ?? 0,
                "imageUrl": uploadedImageUrls,
                "userId": currentUser.uid,
                "supplierId": supplier.id,
                "supplierName": supplier.nama
            ]

            let db = Firestore.firestore()
            db.collection("inventory").addDocument(data: packageData) { error in
                if let error = error {
                    failure(error)
                } else {
                    success()
                    self.resetFields()
                }
            }
        }
    }
    
    func updateStock(from text: String) {
        stock = Int(text) ?? 0
        stockText = text
    }
}
