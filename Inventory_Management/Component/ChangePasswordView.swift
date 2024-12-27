//
//  ChangePasswordView.swift
//  NirvanaTour
//
//  Created by Yohanes  Ari on 25/10/24.
//

import SwiftUI

struct ChangePasswordView: View {
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Current Password")) {
                    SecureField("Enter current password", text: $currentPassword)
                }
                
                Section(header: Text("New Password")) {
                    SecureField("Enter new password", text: $newPassword)
                }
                
                Section(header: Text("Confirm Password")) {
                    SecureField("Re-enter new password", text: $confirmPassword)
                }
                
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.footnote)
                }
                
                Button("Confirm Change") {
                    Task {
                        if newPassword == confirmPassword {
                            errorMessage = ""
                            await viewModel.changePassword(currentPassword: currentPassword, newPassword: newPassword)
                            dismiss()  // Close the sheet
                        } else {
                            errorMessage = "Passwords do not match"
                        }
                    }
                }
                .disabled(currentPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty)
            }
            .navigationTitle("Change Password")
            .navigationBarItems(trailing: Button("Cancel") {
                dismiss()
            })
        }
    }
}
