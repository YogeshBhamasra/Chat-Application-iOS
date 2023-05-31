//
//  ChatUser.swift
//  Chat Application
//
//  Created by Yogesh Rao on 29/05/23.
//  Copyright © 2023 Yogesh Rao. All rights reserved.
//

import Foundation
import FirebaseFirestoreSwift

struct ChatUser: Codable, Identifiable {
    @DocumentID var id: String?
    
    let uid, email, profileImageUrl: String
    var username: String {
        email.components(separatedBy: "@").first ?? email
    }
//    init(_ data: [String: Any]) {
//        self.uid = data[UserData.uid.value] as? String ?? ""
//        self.email = data[UserData.email.value] as? String ?? ""
//        self.profileImageUrl = data[UserData.userProfileImage.value] as? String ?? ""
//        self.username = self.email
//        self.username.removeSubrange((username.firstIndex(of: "@") ?? (username.endIndex))..<username.endIndex)
//    }
    enum CodingKeys: String, CodingKey {
        case id
        case uid
        case email
        case profileImageUrl = "profileImageURL"
    }
}
