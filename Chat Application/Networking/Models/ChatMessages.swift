//
//  ChatMessages.swift
//  Chat Application
//
//  Created by Yogesh Rao on 30/05/23.
//  Copyright © 2023 Yogesh Rao. All rights reserved.
//

import Foundation

struct ChatMessage: Identifiable {
    var id: String {documentId}
    let documentId: String
    let from, to: String
    let imageURL, text: String?
    init(documentId: String, _ data: [String: Any]) {
        self.documentId = documentId
        self.from = data[MessagesData.fromUser.value] as? String ?? ""
        self.to = data[MessagesData.toUser.value] as? String ?? ""
        self.text = data[MessagesData.chatText.value] as? String
        self.imageURL = data[MessagesData.imageURL.value] as? String
    }
}
