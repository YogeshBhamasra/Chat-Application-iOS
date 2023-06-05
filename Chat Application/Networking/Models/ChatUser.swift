//
//  ChatUser.swift
//  Chat Application
//
//  Created by Yogesh Rao on 29/05/23.
//  Copyright © 2023 Yogesh Rao. All rights reserved.
//

import Foundation
import FirebaseFirestoreSwift
import RealmSwift
import Realm

class ChatUser: Codable, Identifiable {
    @DocumentID var id: String?
    var uid, email, profileImageUrl: String
    var username: String {
        email.components(separatedBy: "@").first ?? email
    }
    init(documentId: String, _ data: [String: Any]) {
        self.uid = data[UserData.uid.value] as? String ?? ""
        self.email = data[UserData.email.value] as? String ?? ""
        self.profileImageUrl = data[UserData.userProfileImage.value] as? String ?? ""
        self.id = documentId
//        super.init()
    }
    init(id: String? = nil, uid: String, email: String, profileImageUrl: String) {
        self.id = id
        self.uid = uid
        self.email = email
        self.profileImageUrl = profileImageUrl
//        super.init()
    }
    enum CodingKeys: String, CodingKey {
        case id
        case uid
        case email
        case profileImageUrl = "profileImageURL"
    }
}

class User: Object, Identifiable {
    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    @Persisted var documentId: String?
    @Persisted var uid: String
    @Persisted var email: String
    @Persisted var profileImageUrl: String
    @Persisted var username: String
    override class func primaryKey() -> String? {
        "id"
    }
    required override init() {
        super.init()
    }
    init(documentId: String? = nil, uid: String, email: String, profileImageUrl: String) {
        self.documentId = documentId
        self.uid = uid
        self.email = email
        self.profileImageUrl = profileImageUrl
        self.username = email.components(separatedBy: "@").first ?? email
    }
    func getDictionaryValues() -> [String : Any] {
        return [
            UserData.uid.value : uid,
            UserData.email.value : email,
            UserData.userProfileImage.value : profileImageUrl
        ] as [String : Any]
    }
}
