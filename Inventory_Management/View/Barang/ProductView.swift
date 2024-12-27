//
//  MyPackageView.swift
//  NirvanaTour
//
//  Created by Yohanes  Ari on 19/10/24.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth // Tambahkan FirebaseAuth untuk mengambil user ID

@MainActor
final class ProductViewModel: ObservableObject {
    @Published var product: [InventoryItem] = []
    
    func loadProduct() async {
        guard let currentUser = Auth.auth().currentUser else {
            print("User not logged in")
            return
        }
        
        let db = Firestore.firestore()
        let productRef = db.collection("inventory")
        
        do {
            let snapshot = try await productRef
                .whereField("userId", isEqualTo: currentUser.uid)
                .getDocuments()
            
            let loadedProduct = snapshot.documents.compactMap { document -> InventoryItem? in
                let data = document.data()
                
                return InventoryItem(
                    id: document.documentID,
                    name: data["name"] as? String ?? "",
                    category: data["categories"] as? String ?? "",
                    description: data["description"] as? String ?? "",
                    stock: data["stock"] as? Int ?? 0,
                    price: data["price"] as? Double ?? 0.0,
                    imageUrl: data["imageUrl"] as? [String] ?? [],
                    supplierId: data["supplierId"] as? String ?? "",
                    supplierName: data["supplierName"] as? String ?? ""
                )
            }

            self.product = loadedProduct
        } catch {
            print("Error fetching packages: \(error.localizedDescription)")
        }
    }
}

struct ProductView: View {
    @StateObject private var viewModel = ProductViewModel()
    @State private var showingAddProduct = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    if viewModel.product.isEmpty {
                        emptyStateView
                    } else {
                        productList
                    }
                }
                .refreshable {
                    await viewModel.loadProduct()
                }
            }
            .navigationTitle("Products")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    addButton
                }
            }
            .sheet(isPresented: $showingAddProduct) {
                NavigationStack {
                    AddProductView()
                }
            }
        }
        .task {
            await viewModel.loadProduct()
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "cart")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            Text("No products available")
                .font(.headline)
            Text("Tap + to add your first product")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 100)
    }
    
    private var productList: some View {
        LazyVStack(spacing: 16) {
            ForEach(viewModel.product, id: \.self) { product in
                NavigationLink(destination: DetailProductView(viewModel: DetailProductViewModel(product: product))) {
                    ProductCard(product: product)
                }
            }
        }
        .padding()
    }
    
    private var addButton: some View {
        Button {
            showingAddProduct = true
        } label: {
            Image(systemName: "plus.circle.fill")
                .font(.title3)
        }
    }
}

struct ProductCard: View {
    let product: InventoryItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            productImage
            
            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(.headline)
                    .lineLimit(2)
                    .foregroundColor(.primary)
                
                Text(product.category)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                if !product.supplierName.isEmpty {
                    Text("Supplier: \(product.supplierName)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text(product.price, format: .currency(code: "IDR"))
                        .font(.callout)
                        .bold()
                        .foregroundStyle(.blue)
                    
                    Spacer()
                    
                    Text("\(product.stock)")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .foregroundStyle(.black)
                        .background(Color(.systemGray6))
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 12)
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
    
    private var productImage: some View {
        Group {
            if let imageUrlArray = product.imageUrl,
               let imageUrl = imageUrlArray.first,
               let url = URL(string: imageUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        Rectangle()
                            .fill(Color(.systemGray6))
                            .overlay {
                                ProgressView()
                            }
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure(_):
                        Rectangle()
                            .fill(Color(.systemGray6))
                            .overlay {
                                Image(systemName: "photo")
                                    .foregroundColor(.gray)
                            }
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(height: 160)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
    }
}
