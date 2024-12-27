//
//  DetailPackageView.swift
//  NirvanaTour
//
//  Created by Yohanes  Ari on 18/10/24.
//

import SwiftUI
import FirebaseFirestore

struct DetailProductView: View {
    @StateObject var viewModel: DetailProductViewModel
    @Environment(\.dismiss) var dismiss
    @State private var isEditing = false
    @State private var showDeleteAlert = false
    @State private var showAddTransaction = false
    @State private var selectedTransactionType: Transaction.TransactionType = .incoming
    @State private var transactionQuantity: String = ""
    @State private var transactionDate = Date()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                imageCarousel
                
                VStack(alignment: .leading, spacing: 20) {
                    productHeader
                    productDetails
                    supplierSection
                    descriptionSection
                    priceSection
                    transactionHistory
                    actionButtons
                }
                .padding(20)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showAddTransaction) {
            addTransactionSheet
        }
        .alert("Delete Product", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                viewModel.deleteProduct { dismiss() }
            }
        } message: {
            Text("Are you sure you want to delete this product?")
        }
    }
    
    private var imageCarousel: some View {
        TabView {
            if let urls = viewModel.product.imageUrl, !urls.isEmpty {
                ForEach(urls, id: \.self) { urlString in
                    AsyncImage(url: URL(string: urlString)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        case .failure:
                            Image(systemName: "photo")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                        @unknown default:
                            EmptyView()
                        }
                    }
                }
            } else {
                Image(systemName: "photo")
                    .font(.system(size: 40))
                    .foregroundColor(.gray)
            }
        }
        .frame(height: 300)
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
    }
    
    private var productHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(viewModel.product.name)
                .font(.title)
                .fontWeight(.bold)
            
            Text(viewModel.product.category)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color(.systemGray6))
                .clipShape(Capsule())
        }
    }
    
    private var productDetails: some View {
        HStack(spacing: 20) {
            VStack {
                Text("\(viewModel.product.stock)")
                    .font(.headline)
                Text("Available")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
    
    private var supplierSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Supplier")
                .font(.headline)
            
            Text(viewModel.product.supplierName)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding(.top, 8)
    }
    
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Description")
                .font(.headline)
            
            Text(viewModel.product.description)
                .font(.body)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
    
    private var priceSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Total Price")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(viewModel.product.price, format: .currency(code: "IDR"))
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.blue)
        }
        .padding(.top, 8)
    }
    
    private var transactionHistory: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Transaction History")
                    .font(.headline)
                
                Spacer()
                
                Button {
                    showAddTransaction = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.blue)
                }
            }
            
            if viewModel.transactions.isEmpty {
                Text("No transactions yet")
                    .foregroundColor(.secondary)
                    .padding(.vertical, 8)
            } else {
                ForEach(viewModel.transactions) { transaction in
                    TransactionRow(transaction: transaction)
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    private var actionButtons: some View {
        HStack(spacing: 16) {
            Button {
                showDeleteAlert = true
            } label: {
                Text("Delete")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.red)
                    .cornerRadius(12)
            }

            NavigationLink(destination: EditProductView(viewModel: EditProductViewModel(product: viewModel.product))) {
                Text("Edit")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.blue)
                    .cornerRadius(12)
            }
        }
        .padding(.top, 20)
    }
    
    private var addTransactionSheet: some View {
        NavigationView {
            Form {
                Picker("Transaction Type", selection: $selectedTransactionType) {
                    Text("Stock In").tag(Transaction.TransactionType.incoming)
                    Text("Stock Out").tag(Transaction.TransactionType.outgoing)
                }
                
                TextField("Quantity", text: $transactionQuantity)
                    .keyboardType(.numberPad)
                
                DatePicker("Date", selection: $transactionDate, displayedComponents: [.date, .hourAndMinute])
            }
            .navigationTitle("Add Transaction")
            .navigationBarItems(
                leading: Button("Cancel") {
                    showAddTransaction = false
                },
                trailing: Button("Save") {
                    if let quantity = Int(transactionQuantity) {
                        Task {
                            await viewModel.addTransaction(
                                type: selectedTransactionType,
                                quantity: quantity,
                                date: transactionDate
                            )
                            showAddTransaction = false
                            transactionQuantity = ""
                        }
                    }
                }
                .disabled(transactionQuantity.isEmpty)
            )
        }
    }
}

private struct TransactionRow: View {
    let transaction: Transaction
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(transaction.type == .incoming ? "Stock In" : "Stock Out")
                    .font(.subheadline)
                    .foregroundColor(transaction.type == .incoming ? .green : .red)
                
                Text(transaction.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("\(transaction.type == .incoming ? "+" : "-")\(transaction.quantity)")
                .font(.headline)
                .foregroundColor(transaction.type == .incoming ? .green : .red)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}
