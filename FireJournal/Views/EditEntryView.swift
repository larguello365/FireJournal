//
//  EditEntryView.swift
//  FireJournal
//
//  Created by Lester Arguello on 5/16/25.
//

import SwiftUI
import PhotosUI
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore
import ImageIO
import Vision

struct EditEntryView: View {
    @Environment(AuthController.self) private var authController
    @Environment(\.dismiss) private var dismiss

    let entry: Entry

    // Editable state backed by existing entry
    @State private var caption: String
    @State private var isFavorite: Bool
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    @State private var metadataTimestamp: Date?
    @State private var metadataLatitude: Double?
    @State private var metadataLongitude: Double?

    init(entry: Entry) {
        self.entry = entry
        _caption = State(initialValue: entry.caption)
        _isFavorite = State(initialValue: entry.isFavorite)
        _metadataTimestamp = State(initialValue: entry.metadataTimestamp)
        _metadataLatitude = State(initialValue: entry.metadataLatitute)
        _metadataLongitude = State(initialValue: entry.metadataLongitude)
    }

    var body: some View {
        NavigationStack {
            Form {
                // MARK: Photo Section
                Section(header: Text("Photo")) {
                    if let existingPath = entry.imagePath, selectedImageData == nil {
                        StorageImageView(storagePath: existingPath)
                            .scaledToFit()
                            .frame(maxHeight: 200)
                            .cornerRadius(8)
                    }
                    PhotosPicker(selection: $selectedPhotoItem,
                                 matching: .images,
                                 photoLibrary: .shared()) {
                        Label("Change Photo", systemImage: "photo.on.rectangle.angled")
                    }
                    .onChange(of: selectedPhotoItem) { _, newItem in
                        Task {
                            guard let item = newItem,
                                  let data = try? await item.loadTransferable(type: Data.self)
                            else { return }
                            selectedImageData = data
                            extractEXIF(from: data)
                        }
                    }
                }

                // MARK: Caption Section
                Section(header: Text("Caption")) {
                    TextEditor(text: $caption)
                        .frame(minHeight: 100)
                }

                // MARK: Favorite Toggle
                Section {
                    Button { isFavorite.toggle() } label: {
                        Label(
                            isFavorite ? "Marked as Favorite" : "Mark as Favorite",
                            systemImage: isFavorite ? "heart.fill" : "heart"
                        )
                        .foregroundColor(isFavorite ? .red : .primary)
                    }
                }

                // MARK: Save Button
                Section {
                    Button("Save Changes") {
                        Task { await updateEntry() }
                    }
                }
            }
            .navigationTitle("Edit Entry")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    // MARK: EXIF Extraction
    private func extractEXIF(from data: Data) {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil),
              let props   = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any]
        else { return }
        if let exif = props[kCGImagePropertyExifDictionary] as? [CFString: Any],
           let dateStr = exif[kCGImagePropertyExifDateTimeOriginal] as? String {
            let fmt = DateFormatter()
            fmt.dateFormat = "yyyy:MM:dd HH:mm:ss"
            metadataTimestamp = fmt.date(from: dateStr)
        }
        if let gps = props[kCGImagePropertyGPSDictionary] as? [CFString: Any],
           let lat = gps[kCGImagePropertyGPSLatitude] as? Double,
           let latRef = gps[kCGImagePropertyGPSLatitudeRef] as? String,
           let lon = gps[kCGImagePropertyGPSLongitude] as? Double,
           let lonRef = gps[kCGImagePropertyGPSLongitudeRef] as? String {
            metadataLatitude  = (latRef == "S") ? -lat : lat
            metadataLongitude = (lonRef == "W") ? -lon : lon
        }
    }

    // MARK: Update Logic using Codable
    @MainActor
    private func updateEntry() async {
        guard let docId = entry.id else { return }
        let db = Firestore.firestore()
        let docRef = db
            .collection("users")
            .document(authController.userId)
            .collection("entry")
            .document(docId)

        // 1) Upload a new image if selected
        var imagePath = entry.imagePath
        if let data = selectedImageData {
            let storage = Storage.storage(url: "gs://firejournal-ccfcd.firebasestorage.app")
            let fileName = "\(UUID().uuidString).jpg"
            let path = "users/\(authController.userId)/entryImages/\(fileName)"
            let ref = storage.reference(withPath: path)
            let meta = StorageMetadata(); meta.contentType = "image/jpeg"
            do {
                _ = try await ref.putDataAsync(data, metadata: meta)
                let url = try await ref.downloadURL()
                imagePath = path
            } catch {
                print("Upload error: \(error)")
            }
        }

        // 2) Parse tags
        let parsed = caption
            .split(whereSeparator: { $0.isWhitespace })
            .filter { $0.hasPrefix("#") && $0.count > 1 }
            .map { String($0.dropFirst()) }
        let userTags = parsed.isEmpty ? nil : parsed
        let autoTags: [String]? = [] // skip auto-tagging on edit

        // 3) Assemble updated Entry
        var updatedEntry = entry
        updatedEntry.caption = caption
        updatedEntry.isFavorite = isFavorite
        updatedEntry.metadataTimestamp = metadataTimestamp
        updatedEntry.metadataLatitute = metadataLatitude
        updatedEntry.metadataLongitude = metadataLongitude
        updatedEntry.userTags = userTags
        updatedEntry.autoTags = autoTags
        updatedEntry.imagePath = imagePath

        // 4) Write using Codable and merge
        do {
            try docRef.setData(from: updatedEntry, merge: true)
            dismiss()
        } catch {
            print("Error updating entry: \(error)")
        }
    }
}

#Preview {
    // Sample entry for preview
    let sample = Entry(
        caption: "Sunset at the beach",
        userId: "uid123",
        isFavorite: true,
        autoTags: ["sunset"],
        userTags: ["vacation"],
        metadataTimestamp: Date(),
        metadataLongitude: nil,
        metadataLatitute: nil,
        imagePath: nil,
        id: "doc123",
        createdAt: Date()
    )
    EditEntryView(entry: sample)
}
