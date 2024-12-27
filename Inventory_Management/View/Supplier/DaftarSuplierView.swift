//
//  DaftarSuplierView.swift
//  Inventory_Firebase
//
//  Created by Yohanes  Ari on 13/12/24.
//

import SwiftUI
import FirebaseFirestore


struct DaftarSuplierView: View {
    @State private var suppliers: [Supplier] = []
    @State private var isLoading: Bool = true
    @State private var errorMessage: String? = nil

    let db = Firestore.firestore()

    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView("Memuat data...")
                } else if let errorMessage = errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                } else {
                    List(suppliers) { supplier in
                        NavigationLink(destination: DetailSupplierView(supplier: supplier)) {
                            VStack(alignment: .leading) {
                                Text(supplier.nama)
                                    .font(.headline)
                                Text(supplier.alamat)
                                    .font(.subheadline)
                                Text("Kontak: \(supplier.kontak)")
                                    .font(.subheadline)
                            }
                        }
                    }
                    // Add Button with Gradient
                    NavigationLink(destination: AddSupplierView()) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Tambah Supplier")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.white, Color.lightBlue.opacity(0.7)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(.black)
                        .cornerRadius(12)
                        .shadow(radius: 5)
                        .padding()
                    }
                }
            }
            .navigationTitle("Daftar Supplier")
            .onAppear(perform: fetchSuppliers)
        }
    }

    func fetchSuppliers() {
        db.collection("suppliers").getDocuments { snapshot, error in
            isLoading = false

            if let error = error {
                errorMessage = "Gagal memuat data: \(error.localizedDescription)"
                print("Error fetching suppliers: \(error.localizedDescription)")
                return
            }

            guard let documents = snapshot?.documents else {
                errorMessage = "Data tidak ditemukan."
                print("No documents found in suppliers collection.")
                return
            }

            self.suppliers = documents.compactMap { doc -> Supplier? in
                let data = doc.data()
                print("Document data: \(data)") // Debug log

                guard
                    let nama = data["nama"] as? String,
                    let alamat = data["alamat"] as? String,
                    let latitude = data["latitude"] as? Double,
                    let longitude = data["longitude"] as? Double
                else {
                    print("Invalid document structure: \(doc.data())")
                    return nil
                }

                let kontak: String
                if let kontakString = data["kontak"] as? String {
                    kontak = kontakString
                } else if let kontakInt = data["kontak"] as? Int {
                    kontak = String(kontakInt)
                } else {
                    print("Invalid kontak type: \(data["kontak"] ?? "nil")")
                    return nil
                }

                print("Parsed supplier: \(nama), \(alamat), \(kontak)")
                return Supplier(id: doc.documentID, nama: nama, alamat: alamat, kontak: kontak, latitude: latitude, longitude: longitude)
            }

            if self.suppliers.isEmpty {
                print("No suppliers found.")
            } else {
                print("Suppliers loaded: \(self.suppliers)")
            }
        }
    }

}


#Preview {
    DaftarSuplierView()
}
