//
//  LoginView.swift
//  NirvanaTour
//
//  Created by Yohanes  Ari on 16/10/24.
//

import SwiftUI

struct LoginView: View {
    
    @State private var email = ""
    @State private var password = ""
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        NavigationStack{
            VStack{
                //image
//                Image("logo")
//                    .resizable()
//                    .scaledToFill()
//                    .frame(width: 200, height: 150)
//                    .padding(.vertical, 32)
                
                //title
                Text("Sign In")
                    .font(.title)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading) // Aligns to the leading
                    .padding(.leading)
                    .padding(.top, 16)
                
                //forrm fields
                VStack(spacing: 24) {
                    InputView(text: $email,title: "Email", placeholder: "name@example.com")
                        .autocapitalization(.none)
                    
                    InputView(text: $password,title: "Password", placeholder: "Enter your password", isSecureField: true)
                        
                }
                .padding(.horizontal)
                .padding(.top,32)
                
                //sign in button
                
                Button {
                    Task {
                        try await viewModel.signIn(withEmail: email, password: password)
                    }
                } label: {
                    HStack{
                        Text("SIGN IN")
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
                
                //sign up button
                NavigationLink{
                    RegistrationView()
                        .navigationBarBackButtonHidden(true)
                } label: {
                    HStack(spacing: 3) {
                        Text("Don't have an account?")
                        Text("Sign up")
                            
                            .fontWeight(.bold)
                    }
                    .font(.system(size: 14))
                    .foregroundStyle(Color.lightBlue)
                }
            }
        }
    }
}

extension LoginView: AuthenticationFormProtocol {
    var formIsValid: Bool {
        return !email.isEmpty
        && email.contains("@")
        && !password.isEmpty
        && password.count > 5
    }
}

#Preview {
    LoginView()
}
