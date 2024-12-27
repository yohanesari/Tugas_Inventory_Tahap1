//
//  DetailPackageViewModel.swift
//  NirvanaTour
//
//  Created by Yohanes  Ari on 25/10/24.
//

import SwiftUI
import FirebaseFirestore

@MainActor
final class DetailProductViewModel: ObservableObject {
    @Published var product: InventoryItem
    @Published var transactions: [Transaction] = []
    @Published var showAddTransaction = false
    @Published var supplier: Supplier?
    
    private let db = Firestore.firestore()
    
    init(product: InventoryItem) {
        self.product = product
        fetchTransactions()
        fetchSupplier()
        setupProductListener()
    }
    
    private func setupProductListener() {
            guard let productId = product.id else { return }
            
            db.collection("inventory").document(productId)
                .addSnapshotListener { [weak self] snapshot, error in
                    guard let self = self,
                          let data = snapshot?.data() else { return }
                    
                    // Update only the stock value to avoid overwriting other properties
                    if let newStock = data["stock"] as? Int {
                        self.product.stock = newStock
                    }
                }
        }
    
    private func fetchSupplier() {
        db.collection("suppliers")
            .document(product.supplierId)
            .getDocument { [weak self] snapshot, error in
                if let error = error {
                    print("Error fetching supplier: \(error.localizedDescription)")
                    return
                }
                
                guard let data = snapshot?.data() else {
                    print("No data found for supplier with ID \(self?.product.supplierId ?? "")")
                    return
                }
                
                guard
                    let nama = data["nama"] as? String,
                    let alamat = data["alamat"] as? String,
                    let kontak = data["kontak"] as? String,
                    let latitude = data["latitude"] as? Double,
                    let longitude = data["longitude"] as? Double
                else {
                    print("Invalid data format: \(data)")
                    return
                }
                
                self?.supplier = Supplier(
                    id: snapshot?.documentID ?? "",
                    nama: nama,
                    alamat: alamat,
                    kontak: kontak,
                    latitude: latitude,
                    longitude: longitude
                )
            }
    }

    
    func fetchTransactions() {
        guard let productId = product.id else { return }
        
        db.collection("transactions")
            .whereField("inventoryItemId", isEqualTo: productId)
            .order(by: "date", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let documents = snapshot?.documents else {
                    print("Error fetching transactions: \(error?.localizedDescription ?? "")")
                    return
                }
                
                self?.transactions = documents.compactMap { document in
                    var data = document.data()
                    data["id"] = document.documentID
                    return Transaction(dictionary: data)
                }
            }
    }
    
    func addTransaction(type: Transaction.TransactionType, quantity: Int, date: Date) async {
            guard let productId = product.id else { return }
            
            let transaction = Transaction(
                type: type,
                quantity: quantity,
                date: date,
                inventoryItemId: productId
            )
            
            do {
                // Start a batch write
                let batch = db.batch()
                
                // Add transaction document
                let transactionRef = db.collection("transactions").document()
                batch.setData(transaction.dictionary, forDocument: transactionRef)
                
                // Update inventory stock
                let newStock = type == .incoming ?
                    product.stock + quantity :
                    product.stock - quantity
                
                let productRef = db.collection("inventory").document(productId)
                batch.updateData(["stock": newStock], forDocument: productRef)
                
                // Commit the batch
                try await batch.commit()
                
                // Update local product stock immediately
                await MainActor.run {
                    self.product.stock = newStock
                }
                
            } catch {
                print("Error adding transaction: \(error.localizedDescription)")
            }
        }
    
    func deleteProduct(completion: @escaping () -> Void) {
        guard let productId = product.id else { return }
        
        let db = Firestore.firestore()
        db.collection("inventory").document(productId).delete { error in
            if let error = error {
                print("Error deleting package: \(error.localizedDescription)")
            } else {
                print("Package deleted successfully")
                completion()
            }
        }
    }
    
    
}


