//
//  ShareViewController.swift
//  ShareExtension
//
//  Created by Lester Arguello on 5/16/25.
//

import UIKit
import Social
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class ShareViewController: SLComposeServiceViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        
        signInIfNeeded()
    }
    
    private func signInIfNeeded() {
        guard Auth.auth().currentUser == nil else { return }
        
        let groupDefaults = UserDefaults(suiteName: "group.FireJournal")
        guard
            let email = groupDefaults?.string(forKey: "sharedEmail"),
            let password = groupDefaults?.string(forKey: "sharedPassword")
        else {
            print("No shared credentials found")
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let err = error {
                print("Extension signIn failed:", err)
            } else {
                print("Extension signed in as", result?.user.uid ?? "")
            }
        }
    }
    
    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        return true
    }
    
    override func didSelectPost() {
        // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
        
        // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
        let caption = self.contentText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let items = self.extensionContext?.inputItems as? [NSExtensionItem] ?? []
        for item in items {
            for provider in item.attachments ?? [] {
                if provider.hasItemConformingToTypeIdentifier("public.image") {
                    provider.loadItem(forTypeIdentifier: "public.image", options: nil) { (data, error) in
                        if let url = data as? URL,
                           let imgData = try? Data(contentsOf: url) {
                            // now you have the image data
                            self.postToJournal(caption: caption, imageData: imgData)
                        }
                    }
                }
            }
        }
        
        if items.isEmpty {
            postToJournal(caption: caption, imageData: nil)
        }
    }
    
    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return []
    }
    
    private func postToJournal(caption: String, imageData: Data?) {
      guard let user = Auth.auth().currentUser else { return }
      let uid = user.uid
      let db = Firestore.firestore()
      let storage = Storage.storage()

      Task {
        var imagePath: String? = nil
        var metadataTimestamp: Date?
        var metadataLatitude: Double?
        var metadataLongitude: Double?

        if let data = imageData {
          if let source = CGImageSourceCreateWithData(data as CFData, nil),
             let props  = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any] {
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

          let filename = UUID().uuidString + ".jpg"
          let path = "users/\(uid)/entryImages/\(filename)"
          let ref  = storage.reference(withPath: path)
          let meta = StorageMetadata()
          meta.contentType = "image/jpeg"
          _ = try await ref.putDataAsync(data, metadata: meta)
          imagePath = path
        }

        let parsed = caption
          .split { $0.isWhitespace }
          .filter { $0.hasPrefix("#") && $0.count > 1 }
          .map { String($0.dropFirst()) }
        let userTags = parsed.isEmpty ? nil : parsed
        let autoTags: [String]? = userTags == nil ? [] : []

        let entry = Entry(
          caption: caption,
          userId: uid,
          isFavorite: false,
          autoTags: autoTags,
          userTags: userTags,
          metadataTimestamp: metadataTimestamp,
          metadataLongitude: metadataLongitude,
          metadataLatitute: metadataLatitude,
          imagePath: imagePath
        )

        _ = try db
          .collection("users")
          .document(uid)
          .collection("entry")
          .addDocument(from: entry)

        extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
      }
    }
    
}
