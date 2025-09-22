//
//  Entry.swift
//  ShareExtension
//
//  Created by Lester Arguello on 5/16/25.
//

import FirebaseFirestore

struct Entry: Identifiable, Codable, Hashable {

    var caption: String
    var userId: String
    var isFavorite: Bool = false
    var autoTags: [String]?
    var userTags: [String]?
    var metadataTimestamp: Date?
    var metadataLongitude: Double?
    var metadataLatitute: Double?
    var imagePath: String?
    
    @DocumentID var id: String?
    @ServerTimestamp var createdAt: Date?

}
