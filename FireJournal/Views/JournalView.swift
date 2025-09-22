//
//  JournalView.swift
//  FireJournal
//
//  Created by Andrew Binkowski on 4/25/25.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth


struct JournalView: View {
    @Environment(AuthController.self) private var authController
    @FirestoreQuery var entries: [Entry]
    @State private var searchText = ""
    @State private var showingAddEntry = false
    
    init(userId: String) {
        _entries = FirestoreQuery(collectionPath: "users/\(userId)/entry")
        print(_entries)
    }
    
    // Shared DateFormatter for search
    private static let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .none
        return df
    }()
    
    /// Filters entries by caption, formatted date, userTags, or autoTags
    private var searchResults: [Entry] {
        guard !searchText.isEmpty else { return entries }
        let lower = searchText.lowercased()
        return entries.filter { entry in
            // Caption match
            let captionMatch = entry.caption.lowercased().contains(lower)
            // Date match
            let dateMatch: Bool = {
                guard let date = entry.createdAt else { return false }
                let dateString = JournalView.dateFormatter.string(from: date).lowercased()
                return dateString.contains(lower)
            }()
            // Tags match
            let userTagsMatch = entry.userTags?.contains(where: { $0.lowercased().contains(lower) }) ?? false
            let autoTagsMatch = entry.autoTags?.contains(where: { $0.lowercased().contains(lower) }) ?? false
            return captionMatch || dateMatch || userTagsMatch || autoTagsMatch
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(searchResults) { entry in
                    NavigationLink(value: entry) {
                        EntryRow(entry: entry)
                    }
                }
                .onDelete(perform: deleteItem)
            }
            .listStyle(.plain)
            .navigationTitle("Journal Entries")
            .searchable(text: $searchText)
            .navigationDestination(for: Entry.self) { entry in
                EntryDetailView(entry: entry)
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    EditButton()
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        showingAddEntry = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    Button("Logout") {
                        authController.signOut()
                    }
                }
            }
            .sheet(isPresented: $showingAddEntry) {
                AddEntryView()
                    .environment(authController)
            }
        }
        // Navigation bar styling
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(Color.purple, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
    
    // Delete handler
    private func deleteItem(at offsets: IndexSet) {
        for idx in offsets {
            let entry = searchResults[idx]
            if let docID = entry.id {
                Task {
                    await deleteDocument(documentID: docID)
                }
            }
        }
    }
    
    @MainActor
    private func deleteDocument(documentID: String) async {
        let db = Firestore.firestore()
        let path = "users/\(authController.userId)/entry/\(documentID)"
        do {
            try await db.document(path).delete()
        } catch {
            print("Error deleting document: \(error)")
        }
    }
}


#Preview {
    NavigationView {
        var authController = AuthController()
        return JournalView(userId: authController.userId)
    }
}
