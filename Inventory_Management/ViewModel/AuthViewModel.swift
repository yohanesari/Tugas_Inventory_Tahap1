//
//  AuthViewModel.swift
//  Project_iOS
//
//  Created by Yohanes  Ari on 29/10/24.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

protocol AuthenticationFormProtocol {
    var formIsValid: Bool { get }
}

@MainActor
class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    
    
    init() {
        self.userSession = Auth.auth().currentUser
        
        Task {
            await fetchUser()
        }
    }
    
    func signIn(withEmail email: String, password: String) async throws{
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            await fetchUser()
        } catch {
            print ("DEBUG: Failed to log in user with error \(error.localizedDescription)")
        }
    }
    
    func createUser(withEmail email: String, password: String, fullname: String, noHp: String) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
            let user = User(id: result.user.uid, fullname: fullname, noHp: noHp, email: email)
            let encodedUser = try Firestore.Encoder().encode(user)
            try await Firestore.firestore().collection("users").document(user.id).setData(encodedUser)
            await fetchUser()
        } catch {
            print("DEBUG: Failed to create user with error \(error.localizedDescription)")
        }
    }

    
    func signOut() {
        do {
            try Auth.auth().signOut() // signout user on backend
            self.userSession = nil // wipes out user session and takes us back to login screen
            self.currentUser = nil // wipes out current user data model
        }catch {
            print ("DEBUG: Failed to sign out with error \(error.localizedDescription)")
        }
    }
    
    func changePassword(currentPassword: String, newPassword: String) async {
            guard let user = Auth.auth().currentUser,
                  let email = user.email else { return }
            
            // Create credentials for re-authentication
            let credential = EmailAuthProvider.credential(withEmail: email, password: currentPassword)
            
            do {
                // Re-authenticate user
                try await user.reauthenticate(with: credential)
                print("DEBUG: Re-authentication successful.")
                
                // Update password after successful re-authentication
                try await user.updatePassword(to: newPassword)
                print("DEBUG: Password successfully updated.")
                
            } catch {
                print("DEBUG: Failed to update password with error \(error.localizedDescription)")
            }
        }
        
        func deleteUser() async throws {
            guard let user = Auth.auth().currentUser else { return }
            
            do {
                try await Firestore.firestore().collection("users").document(user.uid).delete()
                try await user.delete()
                self.userSession = nil
                self.currentUser = nil
                print("DEBUG: Account successfully deleted.")
            } catch {
                print("DEBUG: Failed to delete account with error \(error.localizedDescription)")
            }
        }
    
    func fetchUser() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let snapshot = try? await Firestore.firestore().collection("users").document(uid).getDocument() else {return}
        
        self.currentUser = try? snapshot.data(as: User.self)
    }
}
