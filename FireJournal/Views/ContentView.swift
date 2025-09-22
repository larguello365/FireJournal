//
//  ContentView.swift
//  FireJournal
//
//  Created by Andrew Binkowski on 4/24/25.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore


struct ContentView: View {
    
    @Environment(AuthController.self) private var authController
    
    var body: some View {
        Group {
            switch authController.authState {
            case .undefined:
                ProgressView()
            case .notAuthenticated:
                AuthView()
            case .authenticated:
                JournalView(userId: authController.userId)
            }
        }
    }
    
}


#Preview {
    NavigationView {
        ContentView()
    }
}
