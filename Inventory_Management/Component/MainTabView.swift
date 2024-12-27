//
//  MainTabView.swift
//  NirvanaTour
//
//  Created by Yohanes Ari on 17/10/24.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var selectedTab = 0 // State to track the selected tab

    var body: some View {
        if let user = viewModel.currentUser {
            TabView(selection: $selectedTab) {
                DashboardView()
                    .tabItem {
                        Label("Dashboard", systemImage: selectedTab == 0 ? "house.fill" : "house")
                    }
                    .tag(0)


                ProfileView()
                    .tabItem {
                        Label("Akun", systemImage: selectedTab == 1 ? "person.fill" : "person")
                    }
                    .tag(1)
            }
            .accentColor(Color.lightBlue)
        } else {
            ProgressView("Loading user data...")
                .onAppear {
                    Task {
                        await viewModel.fetchUser()
                    }
                }
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthViewModel())
}
