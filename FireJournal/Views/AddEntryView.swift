//
//  AddEntryView.swift
//  FireJournal
//
//  Created by Lester Arguello on 5/16/25.
//

import SwiftUI

import SwiftUI
import PhotosUI
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore
import ImageIO
import Vision


struct AddEntryView: View {
    @Environment(AuthController.self) private var authController
    @Environment(\.dismiss) private var dismiss

    // MARK: - State
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    @State private var caption: String = ""
    @State private var isFavorite: Bool = false

    // EXIF metadata
    @State private var metadataTimestamp: Date?
    @State private var metadataLatitude: Double?
    @State private var metadataLongitude: Double?

    var body: some View {
        NavigationStack {
            Form {
                // Photo picker
                Section(header: Text("Photo")) {
                    PhotosPicker(
                        selection: $selectedPhotoItem,
                        matching: .images,
                        photoLibrary: .shared()
                    ) {
                        if let data = selectedImageData,
                           let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                                .cornerRadius(8)
                        } else {
                            HStack {
                                Image(systemName: "photo.on.rectangle.angled")
                                Text("Select an Image")
                            }
                        }
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

                // Caption
                Section(header: Text("Caption")) {
                    TextEditor(text: $caption)
                        .frame(minHeight: 100)
                }

                // Favorite toggle
                Section {
                    Button { isFavorite.toggle() } label: {
                        Label(
                            isFavorite ? "Marked as Favorite" : "Mark as Favorite",
                            systemImage: isFavorite ? "heart.fill" : "heart"
                        )
                        .foregroundColor(isFavorite ? .red : .primary)
                    }
                }

                // Submit
                Section {
                    Button("Submit Entry") {
                        Task { await submitEntry() }
                    }
                    .disabled(caption.isEmpty && selectedImageData == nil)
                }
            }
            .navigationTitle("New Journal Entry")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    // MARK: - EXIF extraction
    private func extractEXIF(from data: Data) {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil),
              let props = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any]
        else { return }
        // Date Taken
        if let exif = props[kCGImagePropertyExifDictionary] as? [CFString: Any],
           let dateStr = exif[kCGImagePropertyExifDateTimeOriginal] as? String {
            let fmt = DateFormatter()
            fmt.dateFormat = "yyyy:MM:dd HH:mm:ss"
            metadataTimestamp = fmt.date(from: dateStr)
        }
        // GPS Location
        if let gps = props[kCGImagePropertyGPSDictionary] as? [CFString: Any],
           let lat = gps[kCGImagePropertyGPSLatitude] as? Double,
           let latRef = gps[kCGImagePropertyGPSLatitudeRef] as? String,
           let lon = gps[kCGImagePropertyGPSLongitude] as? Double,
           let lonRef = gps[kCGImagePropertyGPSLongitudeRef] as? String {
            metadataLatitude = (latRef == "S") ? -lat : lat
            metadataLongitude = (lonRef == "W") ? -lon : lon
        }
    }

    // MARK: - Submission Logic
    @MainActor
    private func submitEntry() async {
        let db = Firestore.firestore()
        // 1) upload image if exists
        var imagePath: String? = nil
        if let data = selectedImageData {
            let storage = Storage.storage()
            let fileName = "\(UUID().uuidString).jpg"
            let path = "users/\(authController.userId)/entryImages/\(fileName)"
            let ref  = storage.reference(withPath: path)
            let meta = StorageMetadata()
            meta.contentType = "image/jpeg"
            do {
                _ = try await ref.putDataAsync(data, metadata: meta)
                let url = try await ref.downloadURL()
                imagePath = path
            } catch {
                print("Upload error: \(error)")
            }
        }
        
        // 2) tags
        let parsed = caption
            .split(whereSeparator: { $0.isWhitespace })
            .filter { $0.hasPrefix("#") && $0.count > 1 }
            .map { String($0.dropFirst()) }
        let userTags = parsed.isEmpty ? nil : parsed
        let autoTags: [String]? = (userTags == nil) ? await classifyImage() : []
        
        // 3) build Entry
        let entry = Entry(
            caption: caption,
            userId: authController.userId,
            isFavorite: isFavorite,
            autoTags: autoTags,
            userTags: userTags,
            metadataTimestamp: metadataTimestamp,
            metadataLongitude: metadataLongitude,
            metadataLatitute: metadataLatitude,
            imagePath: imagePath
        )
        
        // 4) write via Codable addDocument
        do {
            _ = try db.collection("users")
                .document(authController.userId)
                .collection("entry")
                .addDocument(from: entry)
            dismiss()
        } catch {
            print("Error saving entry: \(error)")
        }
    }
    
    // MARK: - Image Classification
    private func classifyImage() async -> [String] {
        guard let data = selectedImageData,
              let uiImage = UIImage(data: data),
              let cgImage = uiImage.cgImage else { return [] }
        let request = VNClassifyImageRequest()
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try handler.perform([request])
            guard let observations = request.results else {
                return []
            }
            // Filter by confidence threshold (>50%) and dedupe
            let filtered = observations.filter { $0.confidence > 0.5 }
            return Array(Set(filtered.map { $0.identifier }))
        } catch {
            print("Classification error: \(error)")
            return []
        }
    }
}


#Preview {
    AddEntryView()
}
