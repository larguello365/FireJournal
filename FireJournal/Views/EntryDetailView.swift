//
//  EntryDetailView.swift
//  FireJournal
//
//  Created by Andrew Binkowski on 4/25/25.
//

import SwiftUI
import FirebaseStorage

struct EntryDetailView: View {
    @Environment(AuthController.self) private var authController
    @Environment(\.dismiss) private var dismiss
    @State private var showingEdit = false
    
    let entry: Entry
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // 1) Image
                if let path = entry.imagePath {
                    StorageImageView(storagePath: path)
                    // keep its aspect ratio
                        .scaledToFit()
                    // full width, but max 300 points tall
                        .frame(maxWidth: .infinity, maxHeight: 300)
                        .clipped()
                } else {
                    Color.gray
                        .frame(height: 200)
                        .overlay(Text("No Image").foregroundColor(.white))
                }
                
                // 2) Date
                if let metaDate = entry.metadataTimestamp {
                    Text(metaDate.formatted(
                        .dateTime.month().day().year().hour().minute()))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                } else if let date = entry.createdAt {
                    Text(date.formatted(
                        .dateTime.month().day().year().hour().minute()))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                }
                
                // 3) Caption
                Text(entry.caption)
                    .font(.title2)
                    .padding(.vertical, 4)
                
                // 4) Tags
                let allTags = (entry.userTags ?? []) + (entry.autoTags ?? [])
                if !allTags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(allTags, id: \.self) { tag in
                                Text("#\(tag)")
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.purple.opacity(0.2))
                                    .foregroundColor(.purple)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Entry")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit") {
                    showingEdit = true
                }
            }
        }
        .sheet(isPresented: $showingEdit) {
            EditEntryView(entry: entry)
                .environment(authController)
        }
    }
}
