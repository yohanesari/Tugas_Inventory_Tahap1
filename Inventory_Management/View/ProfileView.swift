//
//  OrderView.swift
//  iOS_Coffee
//
//  Created by Yohanes  Ari on 15/11/24.
//

import SwiftUI

struct ProfileView: View {
    
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var isShowingChangePasswordSheet = false  // State to show sheet

    var body: some View {
        NavigationView { // Tambahkan NavigationView di sini
            if let user = viewModel.currentUser {
                List {
                    Section {
                        HStack {
                            Text(user.initials)
                                .font(.title)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(width: 72, height: 72)
                                .background(Color(.systemGray3))
                                .clipShape(Circle())
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(user.fullname)
                                    .fontWeight(.semibold)
                                    .padding(.top, 4)
                                Text(user.email)
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    
                    Section("General") {
                        HStack {
                            SettingsRowView(imageName: "gear", title: "Version", tintColor: Color(.gray))
                            Spacer()
                            Text("1.0.0")
                                .font(.subheadline)
                                .foregroundStyle(.gray)
                        }
                        
//                        NavigationLink(destination: HistoryView()) {
//                            SettingsRowView(imageName: "clock", title: "History", tintColor: .blue)
//                        }
                    }
                    
                    Section("Account") {
                        Button {
                            isShowingChangePasswordSheet = true  // Show change password sheet
                        } label: {
                            SettingsRowView(imageName: "key.fill", title: "Change Password", tintColor: .blue)
                        }
                        .sheet(isPresented: $isShowingChangePasswordSheet) {
                            ChangePasswordView()
                        }
                        
                        Button {
                            Task {
                                try await viewModel.deleteUser()
                            }
                        } label: {
                            SettingsRowView(imageName: "trash.circle.fill", title: "Delete Account", tintColor: .red)
                        }
                        
                        Button {
                            viewModel.signOut()
                        } label: {
                            SettingsRowView(imageName: "arrow.left.circle.fill", title: "Sign Out", tintColor: .red)
                        }
                    }
                }
            } else {
                LoginView()
            }
        }
    }
}

#Preview {
    ProfileView()
}

