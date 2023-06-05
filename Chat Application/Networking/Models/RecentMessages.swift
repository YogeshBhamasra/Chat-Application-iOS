//
//  RecentMessages.swift
//  Chat Application
//
//  Created by Yogesh Rao on 30/05/23.
//  Copyright © 2023 Yogesh Rao. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift
import RealmSwift

class RecentMessages: Codable, Identifiable {
    @DocumentID var id: String?
    let text, fromId, toId, email, profileImageUrl : String
    let timestamp: Date
    enum CodingKeys: String, CodingKey {
        case id
        case text = "text"
        case fromId = "from"
        case toId = "to"
        case email = "email"
        case profileImageUrl = "profileImageURL"
        case timestamp = "timestamp"
    }
    var username: String {
        email.components(separatedBy: "@").first ?? email
    }
    
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: timestamp, relativeTo: Date())
    }
}

class RecentMessageLocal: Object, Identifiable {
    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    @Persisted var text : String
    @Persisted var fromId : String
    @Persisted var toId : String
    @Persisted var email : String
    @Persisted var profileImageUrl : String
    @Persisted var timestamp: Date
    @Persisted var username: String
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: timestamp, relativeTo: Date())
    }
    override class func primaryKey() -> String? {
        "id"
    }
    override required init() {
        super.init()
    }
}
