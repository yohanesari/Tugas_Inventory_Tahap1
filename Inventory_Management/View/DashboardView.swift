//
//  HomeView.swift
//  Inventory_Firebase
//
//  Created by Yohanes  Ari on 13/12/24.
//

import SwiftUI
import FirebaseFirestore

struct DashboardView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var totalSuppliers: Int = 0
    @State private var totalProduct: Int = 0
    @State private var isLoading: Bool = true
    
    let db = Firestore.firestore()
    
    var body: some View {
        NavigationStack {
            if let user = viewModel.currentUser {
                ScrollView {
                    VStack(spacing: 20) {
                        // User Greeting
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Selamat Datang,")
                                    .font(.headline)
                                Text(user.fullname)
                                    .font(.title2)
                                    .fontWeight(.bold)
                            }
                            Spacer()
                        }
                        .padding()
                        
                        // Dashboard Cards
                        VStack(spacing: 20) {
                            // Barang Card
                            NavigationLink(destination: ProductView()) {
                                DashboardCardView(
                                    icon: "shippingbox.fill",
                                    title: "Barang",
                                    desc: "Total Barang",
                                    count: isLoading ? "..." : "\(totalProduct)" // Menampilkan total barang
                                )
                            }
                            
                            // Supplier Card
                            NavigationLink(destination: DaftarSuplierView()) {
                                DashboardCardView(
                                    icon: "person.2",
                                    title: "Supplier",
                                    desc: "Total Supplier",
                                    count: isLoading ? "..." : "\(totalSuppliers)"
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .navigationTitle("Dashboard")
                .navigationBarTitleDisplayMode(.inline)
                .onAppear {
                    fetchProductCount()
                    fetchSupplierCount()
                }
            } else {
                LoginView()
            }
        }
    }
    
    // Fungsi menghitung jumlah supplier
    func fetchSupplierCount() {
        isLoading = true
        db.collection("suppliers").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching supplier count: \(error.localizedDescription)")
                isLoading = false
                return
            }
            
            totalSuppliers = snapshot?.documents.count ?? 0
            isLoading = false
        }
    }
    
    func fetchProductCount() {
        isLoading = true
        db.collection("inventory").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching product count: \(error.localizedDescription)")
                isLoading = false
                return
            }
            
            totalProduct = snapshot?.documents.count ?? 0
            isLoading = false
        }
    }
}

// Reusable Dashboard Card View
struct DashboardCardView: View {
    let icon: String
    let title: String
    let desc: String
    let count: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .resizable()
                .scaledToFit()
                .frame(width: 35, height: 35)
                .foregroundColor(.black)
                .padding()
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.system(size: 35))
                    .foregroundColor(.black)
                Spacer()
                
                Text(desc)
                    .font(.system(size: 14))
                    .foregroundColor(.black)
                Text(count)
                    .font(.system(size: 18))
                    .fontWeight(.bold)
                    .foregroundColor(.black)
            }
            .padding(.vertical, 35)
            
            Spacer()
        }
        .frame(height: 180)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.white, Color.lightBlue.opacity(0.7)]),
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(15)
        .shadow(color: .gray.opacity(0.3), radius: 5, x: 0, y: 2)
        
    }
}
