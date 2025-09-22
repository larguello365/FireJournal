//
//  StorageImageView.swift
//  FireJournal
//
//  Created by Lester Arguello on 5/16/25.
//

import SwiftUI
import FirebaseStorage

struct StorageImageView: View {
    let storagePath: String
    @State private var uiImage: UIImage?
    
    var body: some View {
        Group {
            if let img = uiImage {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
            } else {
                ProgressView()
            }
        }
        .onAppear(perform: loadImage)
    }
    
    private func loadImage() {
        let ref = Storage.storage().reference(withPath: storagePath)
        ref.getData(maxSize: 5 * 1024 * 1024) { data, error in
            if let error = error {
                print("Storage image load failed:", error)
                return
            }
            if let data, let img = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.uiImage = img
                }
            }
        }
    }
}
