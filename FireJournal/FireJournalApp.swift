//
//  FireJournalApp.swift
//  FireJournal
//
//  Created by Andrew Binkowski on 4/24/25.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        //        FirebaseApp.configure()
        return true
    }
}

@main

struct FireJournalApp: App {
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @State private var authController = AuthController()
    
    init() {
        FirebaseApp.configure()
        
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(authController)
                .onAppear {
                    authController.listenToAuthChanges()
                }
        }
    }
}
