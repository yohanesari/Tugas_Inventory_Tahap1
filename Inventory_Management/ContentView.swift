//
//  ContentView.swift
//  Inventory_Management
//
//  Created by Yohanes  Ari on 26/11/24.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var viewModel: AuthViewModel

    var body: some View {
        Group {
            if viewModel.userSession != nil {
                // Menampilkan MainTabView dengan tab menu setelah user login
                MainTabView()
            } else {
                // Menampilkan LoginView saat user belum login
                LoginView()
            }
        }
    }
}

#Preview {
    ContentView()
}
