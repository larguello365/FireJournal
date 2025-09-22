//
//  AuthView.swift
//  FireJournal
//
//  Created by Andrew Binkowski on 4/25/25.
//

import SwiftUI

struct AuthView: View {
    @Environment(AuthController.self) private var authController
    
    @State private var email = ""
    @State private var password = ""
    @State private var isSignUp  = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        VStack {
            Spacer()
            Image(systemName: "person.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
                .padding()
            
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            
            Button {
                authenticate()
            } label: {
                HStack {
                    Text("\(isSignUp ? "Sign Up" : "Sign In")")
                        .font(.title)
                }
            }
            .padding()
            .buttonStyle(.borderedProminent)
            
            if let errorMessage = authController.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            }
            
            Button("\(isSignUp ? "I have an account" : "I need an account")") {
                isSignUp.toggle()
            }
            .padding()
            
            Button("Forgot Password?") {
                forgotPassword()
            }
            .padding()
        }
        .padding()
        .navigationTitle("Welcome")
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Password Reset"),
                  message: Text(alertMessage),
                  dismissButton: .default(Text("OK")))
        }
    }
    
    //
    // MARK: - Sign Up/In
    //
    func authenticate () {
        isSignUp ? signUp() : signIn()
        
    }
    
    func signIn() {
        Task {
            do {
                try await authController.signIn(email: email, password: password)
                let groupDefaults = UserDefaults(suiteName: "group.FireJournal")
                groupDefaults?.set(email, forKey: "sharedEmail")
                groupDefaults?.set(password, forKey: "sharedPassword")
                groupDefaults?.synchronize()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func signUp() {
        Task {
            do {
                try await authController.signUp(email: email, password: password)
                let groupDefaults = UserDefaults(suiteName: "group.FireJournal")
                groupDefaults?.set(email, forKey: "sharedEmail")
                groupDefaults?.set(password, forKey: "sharedPassword")
                groupDefaults?.synchronize()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func forgotPassword() {
        guard !email.isEmpty else {
            alertMessage = "Please enter your email first."
            showingAlert = true
            return
        }
        
        Task {
            do {
                try await authController.resetPassword(email: email)
                alertMessage = "If that address is registered, you’ll receive a password‐reset email shortly."
            } catch {
                alertMessage = error.localizedDescription
            }
            showingAlert = true
        }
    }
}



#Preview {
    var authController = AuthController()
    return AuthView()
        .environment(authController)
        .onAppear {
            authController.listenToAuthChanges()
        }
}
