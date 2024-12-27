//
//  AddSuplierView.swift
//  Inventory_Firebase
//
//  Created by Yohanes  Ari on 13/12/24.
//

import SwiftUI

struct AddSupplierView: View {
    @StateObject private var viewModel = AddSupplierViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Informasi Supplier")) {
                    TextField("Nama Supplier", text: $viewModel.nama)
                    TextField("Alamat", text: $viewModel.alamat)
                    TextField("Kontak (Telp/Email)", text: $viewModel.kontak)
                        .keyboardType(.phonePad)
                }
                
                Section(header: Text("Lokasi")) {
                    Button(action: {
                        viewModel.requestLocation()
                    }) {
                        HStack {
                            Image(systemName: "location.fill")
                            Text("Ambil Lokasi Sekarang")
                        }
                        .foregroundColor(.blue)
                    }
                    
                    if let latitude = viewModel.latitude, let longitude = viewModel.longitude {
                        Text("Koordinat: \(latitude), \(longitude)")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
                
                if let errorMessage = viewModel.errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                }
                
                Section {
                    Button(action: {
                        viewModel.saveSupplier()
                    }) {
                        HStack {
                            Spacer()
                            if viewModel.isLoading {
                                ProgressView()
                            } else {
                                Text("Simpan Supplier")
                            }
                            Spacer()
                        }
                    }
                    .disabled(viewModel.isLoading)
                }
            }
            .navigationTitle("Tambah Supplier")
        }
    }
}

// Preview Provider
#Preview {
    AddSupplierView()
}
