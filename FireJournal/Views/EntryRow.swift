//
//  EntryRow.swift
//  FireJournal
//
//  Created by Lester Arguello on 5/16/25.
//

import SwiftUI
import FirebaseFirestore

struct EntryRow: View {
    let entry: Entry

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Thumbnail
            if let path = entry.imagePath {
              StorageImageView(storagePath: path)
                .frame(width: 60, height: 60)
                .clipped()
                .cornerRadius(6)
            } else {
              Color.gray.frame(width: 60, height: 60).cornerRadius(6)
            }

            // Text content
            VStack(alignment: .leading, spacing: 4) {
                // Date
                if let metadate = entry.metadataTimestamp {
                    Text(metadate.formatted(.dateTime.month().day().year()))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else if let date = entry.createdAt {
                    Text(date.formatted(.dateTime.month().day().year()))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                // Blurb (caption)
                Text(entry.caption)
                    .font(.body)
                    .lineLimit(2)
            }

            Spacer()

            // Favorite icon
            if entry.isFavorite {
                Image(systemName: "heart.fill")
                    .foregroundColor(.red)
            }
        }
        .padding(.vertical, 8)
    }
}
