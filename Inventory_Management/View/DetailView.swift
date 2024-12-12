//
//  DetailView.swift
//  Inventory_Management
//
//  Created by Yohanes Ari on 29/11/24.
//

import SwiftUI

class TransactionManager: ObservableObject {
    @Published var transactionHistory: [Transaction] = []

    private let userDefaultsKey: String

    init(for itemID: String) {
        self.userDefaultsKey = "transactions_\(itemID)"
        loadTransactions()
    }

    func addTransaction(_ transaction: Transaction) {
        transactionHistory.append(transaction)
        saveTransactions()
    }

    private func loadTransactions() {
        if let savedTransactionsData = UserDefaults.standard.data(forKey: userDefaultsKey),
           let savedTransactions = try? JSONDecoder().decode([Transaction].self, from: savedTransactionsData) {
            transactionHistory = savedTransactions
        }
    }

    private func saveTransactions() {
        do {
            let encodedData = try JSONEncoder().encode(transactionHistory)
            UserDefaults.standard.set(encodedData, forKey: userDefaultsKey)
        } catch {
            print("Error saving transactions: \(error)")
        }
    }
}

struct DetailView: View {
    @State private var item: InventoryItem
    @State private var showAddRiwayatSheet = false
    @ObservedObject private var transactionManager: TransactionManager

    init(item: InventoryItem) {
        self._item = State(initialValue: item)
        self.transactionManager = TransactionManager(for: item.id.uuidString)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                itemImageView
                itemInfoView
                itemDescriptionView
                addTransactionButton
                transactionHistoryView
            }
            .padding()
        }
        .navigationTitle("Detail Barang")
        .sheet(isPresented: $showAddRiwayatSheet) {
            AddRiwayatView(item: $item, transactionManager: transactionManager)
        }
    }

    // MARK: - Views

    private var itemImageView: some View {
        Group {
            if let data = item.imageData,
               let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: 300)
                    .cornerRadius(10)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(maxWidth: .infinity, maxHeight: 300)
                    .cornerRadius(10)
            }
        }
    }

    private var itemInfoView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(item.name)
                .font(.title2)
                .bold()
            Text("Stok: \(item.stock)")
                .foregroundColor(.black)
            Text("Harga: Rp \(item.price, specifier: "%.2f")")
                .foregroundColor(.black)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
    }

    private var itemDescriptionView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Deskripsi")
                .font(.headline)
            Text(item.description)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
    }

    private var addTransactionButton: some View {
        Button(action: {
            showAddRiwayatSheet = true
        }) {
            HStack {
                Image(systemName: "plus.circle.fill")
                Text("Tambah Riwayat")
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
    }

    private var transactionHistoryView: some View {
        VStack(alignment: .leading) {
            Text("Riwayat Transaksi")
                .font(.headline)

            if transactionManager.transactionHistory.isEmpty {
                Text("Belum ada riwayat transaksi")
                    .foregroundColor(.gray)
            } else {
                ForEach(transactionManager.transactionHistory.indices, id: \.self) { index in
                    HStack {
                        transactionRowView(transactionManager.transactionHistory[index])

                        Button(action: {
                            deleteTransaction(at: index)
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
        }
    }

    private func transactionRowView(_ transaction: Transaction) -> some View {
        HStack {
            Image(systemName: transaction.type == .masuk ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
                .foregroundColor(transaction.type == .masuk ? .green : .red)
            Text(transaction.type.rawValue.capitalized)
                .bold()
            Spacer()
            Text("\(transaction.amount) barang")
            Spacer()
            Text(transaction.date, style: .date)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
    }

    private func deleteTransaction(at index: Int) {
        transactionManager.transactionHistory.remove(at: index)
    }
}
