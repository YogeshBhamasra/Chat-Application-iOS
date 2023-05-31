//
//  FirebaseCollections.swift
//  Chat Application
//
//  Created by Yogesh Rao on 29/05/23.
//  Copyright © 2023 Yogesh Rao. All rights reserved.
//

import Foundation

enum Collections: String {
    case userCollection = "users"
    case userMessages = "messages"
    case recentMessages = "recent_messages"
    var value: String {
        return self.rawValue
    }
}
enum MessagesData: String {
    case fromUser = "from"
    case toUser = "to"
    case chatText = "text"
    case chatTimestamp = "timestamp"
    case imageURL = "imageURL"
    var value: String {
        return self.rawValue
    }
}
enum UserData: String {
    case uid = "uid"
    case email = "email"
    case userProfileImage = "profileImageURL"
    var value: String {
        return self.rawValue
    }
}
