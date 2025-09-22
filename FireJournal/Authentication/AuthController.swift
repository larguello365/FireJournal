//
//  AuthController.swift
//  FireJournal
//
//  Created by Andrew Binkowski on 4/25/25.
//

import SwiftUI
import FirebaseAuth


enum AuthState {
    case undefined, authenticated, notAuthenticated
}

@Observable class AuthController {
    
    var email = ""
    var password = ""
    var isLoggedIn = false
    var errorMessage: String?
    var authState: AuthState = .undefined
    
    var userId: String = ""
    
    
    func listenToAuthChanges() {
        _ = Auth.auth().addStateDidChangeListener { auth, user in
            self.authState = user != nil ? .authenticated : .notAuthenticated
            if let user = Auth.auth().currentUser {
                self.userId = user.uid
                print("User ID: \(self.userId)")
            } else {
                print("No user is signed in.")
            }
        }
    }
    
    func signUp(email: String, password: String) async {
        do {
            try await Auth.auth().createUser(withEmail: email, password: password)
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    func signIn(email: String, password: String) async throws {
        do {
            try await Auth.auth().signIn(withEmail: email, password: password)
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.isLoggedIn = false
            self.errorMessage = nil
            self.authState = .notAuthenticated
        } catch {
            self.errorMessage = error.localizedDescription
        }
        
    }
    
    func resetPassword(email: String) async throws {
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
}
