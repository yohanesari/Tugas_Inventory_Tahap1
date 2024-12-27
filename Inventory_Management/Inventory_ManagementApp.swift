//
//  Inventory_ManagementApp.swift
//  Inventory_Management
//
//  Created by Yohanes  Ari on 26/11/24.
//

import SwiftUI
import Firebase

@main
struct Inventory_ManagementApp: App {
    @StateObject var viewModel =  AuthViewModel()
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
    }
}
