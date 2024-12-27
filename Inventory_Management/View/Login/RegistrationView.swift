//
//  RegistrationView.swift
//  NirvanaTour
//
//  Created by Yohanes  Ari on 16/10/24.
//

import SwiftUI

struct RegistrationView: View {
    
    @State private var email = ""
    @State private var fullname = ""
    @State private var noHp = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: AuthViewModel
    
    
    var body: some View {
        VStack {
        
            //title
            Text("SIGN UP")
                .font(.title)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading) // Aligns to the leading
                .padding(.leading)
                .padding(.top, 16)
            
            
            //forrm fields
            VStack(spacing: 24) {
                InputView(text: $email,title: "Email", placeholder: "name@example.com")
                    .autocapitalization(.none)
                
                InputView(text: $fullname,title: "Full Name", placeholder: "Enter Your Name")
                
                InputView(text: $noHp,title: "No Handphone", placeholder: "Enter your number phone")
                
                InputView(text: $password,title: "Password", placeholder: "Enter your password", isSecureField: true)
                
                ZStack{
                    InputView(text: $confirmPassword,title: "Confirm Password", placeholder: "Confirm your password", isSecureField: true)
                    
                    if !password.isEmpty && !confirmPassword.isEmpty {
                        if password == confirmPassword {
                            Image(systemName: "checkmark.circle.fill")
                                .imageScale(.large)
                                .fontWeight(.bold)
                                .foregroundColor(Color(.systemGray))
                        } else {
                            Image(systemName: "xmark.circle.fill")
                                .imageScale(.large)
                                .fontWeight(.bold)
                                .foregroundColor(Color(.systemRed))
                        }
                    }
                }
                    
            }
            .padding(.horizontal)
            .padding(.top,12)
            
            //sign up button
            
            Button {
                Task {
                    try await viewModel.createUser(withEmail: email, password: password, fullname: fullname, noHp: noHp)
                    }
                } label: {
                    HStack {
                        Text("SIGN UP")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.black)
                    .frame(width: UIScreen.main.bounds.width - 32, height: 48)
                }
                .background(Color.lightBlue)
                .disabled(!formIsValid)
                .opacity(formIsValid ? 1.0 : 0.5)
                .cornerRadius(10)
                .padding(.top, 24)
                        
            Spacer()
            
            Button{
                dismiss()
            } label: {
                HStack(spacing: 3) {
                    Text("Already have an account?")
                    Text("Sign in")
                        
                        .fontWeight(.bold)
                }
                .font(.system(size: 14))
                .foregroundStyle(Color.lightBlue)
            }
        }
    }
}
extension RegistrationView: AuthenticationFormProtocol {
    var formIsValid: Bool {
        return !email.isEmpty
        && email.contains("@")
        && !password.isEmpty
        && password.count > 5
        && confirmPassword == password
        && !fullname.isEmpty
        && !noHp.isEmpty
    }
}

#Preview {
    RegistrationView()
}
