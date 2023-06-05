//
//  ChatMessages.swift
//  Chat Application
//
//  Created by Yogesh Rao on 30/05/23.
//  Copyright © 2023 Yogesh Rao. All rights reserved.
//

import Foundation
import RealmSwift

class ChatMessage: Identifiable {
    var id: String {documentId}
    let documentId: String
    let from, to: String
    let timestamp: Date
    let imageURL, text: String?
    init(documentId: String, _ data: [String: Any]) {
        self.documentId = documentId
        self.from = data[MessagesData.fromUser.value] as? String ?? ""
        self.to = data[MessagesData.toUser.value] as? String ?? ""
        self.text = data[MessagesData.chatText.value] as? String
        self.imageURL = data[MessagesData.imageURL.value] as? String
        self.timestamp = data[MessagesData.chatTimestamp.value] as? Date ?? Date()
    }
}
class UserMessage: Object {
    @Persisted(primaryKey: true) var id : String = UUID().uuidString
    @Persisted var withUser: String
    @Persisted var messages: List<Message>
    override class func primaryKey() -> String? {
        "id"
    }
    required override init() {
        super.init()
    }
}
class Message: Object, Identifiable {
    @Persisted(primaryKey: true) var id : String = UUID().uuidString
    @Persisted var from: String
    @Persisted var to: String
    @Persisted var timestamp: Date
    @Persisted var imageURL: String?
    @Persisted var text: String?
    override class func primaryKey() -> String? {
        "id"
    }
    required override init() {
        super.init()
    }
    init(_ data: [String: Any]) {
        self.from = data[MessagesData.fromUser.value] as? String ?? ""
        self.to = data[MessagesData.toUser.value] as? String ?? ""
        self.text = data[MessagesData.chatText.value] as? String
        self.imageURL = data[MessagesData.imageURL.value] as? String
        self.timestamp = data[MessagesData.chatTimestamp.value] as? Date ?? Date()
    }
    init(chatMessage: ChatMessage) {
        self.from = chatMessage.from
        self.to = chatMessage.to
        self.text = chatMessage.text
        self.imageURL = chatMessage.imageURL
        self.timestamp = chatMessage.timestamp
    }
}
