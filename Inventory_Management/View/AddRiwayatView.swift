//
//  AddRiwayatView.swift
//  Inventory_Management
//
//  Created by Yohanes  Ari on 05/12/24.
//

import SwiftUI

struct AddRiwayatView: View {
    @Binding var item: InventoryItem
    @ObservedObject var transactionManager: TransactionManager
    @Environment(\.dismiss) var dismiss

    @State private var selectedType: TransactionType = .masuk
    @State private var amount: Int = 0
    @State private var date = Date()

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Jenis Transaksi")) {
                    Picker("Pilih Jenis", selection: $selectedType) {
                        ForEach(TransactionType.allCases, id: \.self) { type in
                            Text(type.rawValue.capitalized).tag(type)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }

                Section(header: Text("Jumlah Barang")) {
                    TextField("Masukkan jumlah", value: $amount, formatter: NumberFormatter())
                        .keyboardType(.numberPad)
                }

                Section(header: Text("Tanggal")) {
                    DatePicker("Pilih tanggal", selection: $date, displayedComponents: .date)
                }
            }
            .navigationTitle("Tambah Riwayat")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Batal") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Simpan") {
                        addTransaction()
                        dismiss()
                    }
                }
            }
        }
    }

    private func addTransaction() {
        guard amount > 0 else { return }
        if selectedType == .keluar && amount > item.stock {
            print("Error: Stok tidak mencukupi")
            return
        }

        // Update stok
        if selectedType == .masuk {
            item.stock += amount
        } else if selectedType == .keluar {
            item.stock -= amount
        }

        // Tambahkan transaksi
        let newTransaction = Transaction(type: selectedType, amount: amount, date: date)
        transactionManager.addTransaction(newTransaction)
    }
}
