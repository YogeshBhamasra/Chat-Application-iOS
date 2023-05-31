//
//  ChatViewModel.swift
//  Chat Application
//
//  Created by Yogesh Rao on 30/05/23.
//  Copyright © 2023 Yogesh Rao. All rights reserved.
//

import SwiftUI
import Firebase

class ChatViewModel: ObservableObject {
    @Published var chatText: String = ""
    @Published var errorMessages: String = ""
    @Published var count = 0
    @Published var image: UIImage?
    @Published var chatMessages = [ChatMessage]()
    let chatUser: ChatUser?
    var firestoreListener: ListenerRegistration?
    init(chatUser: ChatUser?) {
        self.chatUser = chatUser
        fetchMessages()
    }
    private func fetchMessages() {
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid,
              let toId = chatUser?.uid else {return}
        firestoreListener?.remove()
        firestoreListener = FirebaseManager.shared.firestore
            .collection(Collections.userMessages.value)
            .document(fromId)
            .collection(toId)
            .order(by: MessagesData.chatTimestamp.value)
            .addSnapshotListener { querySnapshot, error in
                if let error {
                    self.errorMessages = "Failed to get messages: \(error.localizedDescription)"
                    return
                }
                querySnapshot?.documentChanges.forEach({ change in
                    if change.type == .added {
                        let data = change.document.data()
                        let id = change.document.documentID
                        self.chatMessages.append(.init(documentId: id, data))
                    }
                })
                DispatchQueue.main.async { [weak self] in
                    self?.count += 1
                }
            }
    }
    func sendMessage() {
        debugPrint(chatText)
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid,
              let toId = chatUser?.uid else {return}
        let document = FirebaseManager.shared.firestore.collection(Collections.userMessages.value)
            .document(fromId)
            .collection(toId)
            .document()
        let messagesData = [MessagesData.fromUser.value: fromId,
                            MessagesData.toUser.value: toId,
                            MessagesData.chatText.value : self.chatText,
                            MessagesData.chatTimestamp.value: Timestamp()] as [String : Any]
        document.setData(messagesData) { error in
            if let error {
                self.errorMessages = "Failed to get message from database: \(error)"
                return
            }
        }
        let recipientMessageDocument = FirebaseManager.shared.firestore.collection(Collections.userMessages.value)
            .document(toId)
            .collection(fromId)
            .document()
        recipientMessageDocument.setData(messagesData) { error in
            if let error {
                self.errorMessages = "Failed to get message from database: \(error)"
                return
            }
        }
        self.persistRecentMessages()
        chatText = ""
        self.count += 1
    }
    private func persistRecentMessages() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid,
              let chatUser else {return}
        let toId = chatUser.uid
        let document = FirebaseManager.shared.firestore
            .collection(Collections.recentMessages.value)
            .document(uid)
            .collection(Collections.userMessages.value)
            .document(toId)
        
        let data: [String: Any] = [
            MessagesData.chatTimestamp.value : Timestamp(),
            MessagesData.chatText.value : self.chatText,
            MessagesData.fromUser.value : uid,
            MessagesData.toUser.value : toId,
            UserData.userProfileImage.value : chatUser.profileImageUrl,
            UserData.email.value : chatUser.email
        ]
        document.setData(data) { error in
            if let error {
                self.errorMessages = "Failed to save recent messages: \(error.localizedDescription)"
                return
            }
        }
        
        guard let currentUser = FirebaseManager.shared.currentUser else { return }
        let recipientRecentMessageDictionary = [
            MessagesData.chatTimestamp.value: Timestamp(),
            MessagesData.chatText.value: self.chatText,
            MessagesData.fromUser.value: uid,
            MessagesData.toUser.value: toId,
            UserData.userProfileImage.value: currentUser.profileImageUrl,
            UserData.email.value: currentUser.email
        ] as [String : Any]
        
        FirebaseManager.shared.firestore
            .collection(Collections.recentMessages.value)
            .document(toId)
            .collection(Collections.userMessages.value)
            .document(currentUser.uid)
            .setData(recipientRecentMessageDictionary) { error in
                if let error = error {
                    print("Failed to save recipient recent message: \(error)")
                    return
                }
            }
    }
    func handleImages() {
        var imageUrl: URL?
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid,
              let toId = chatUser?.uid else {return}
        guard let imageData = self.image?.jpegData(compressionQuality: 0.5) else {return}
        let ref = FirebaseManager.shared.storage.reference(withPath: fromId)
        ref.putData(imageData) { metadata, error in
            if let error {
                self.errorMessages = "Failed to push image in Storage: \(error)"
                return
            }
            ref.downloadURL { url, error in
                if let error {
                    self.errorMessages = "Failed to retrieve downloadURL: \(error)"
                    return
                }
                guard let url else {return}
                imageUrl = url
            }
        }
        let document = FirebaseManager.shared.firestore.collection(Collections.userMessages.value)
            .document(fromId)
            .collection(toId)
            .document()
        let messagesData = [MessagesData.fromUser.value: fromId,
                            MessagesData.toUser.value: toId,
                            MessagesData.imageURL.value : imageUrl?.absoluteString ?? "",
                            MessagesData.chatTimestamp.value: Timestamp()] as [String : Any]
        document.setData(messagesData) { error in
            if let error {
                self.errorMessages = "Failed to get message from database: \(error)"
                return
            }
        }
        let recipientMessageDocument = FirebaseManager.shared.firestore.collection(Collections.userMessages.value)
            .document(toId)
            .collection(fromId)
            .document()
        recipientMessageDocument.setData(messagesData) { error in
            if let error {
                self.errorMessages = "Failed to get message from database: \(error)"
                return
            }
        }
        self.chatText = "image"
        self.persistRecentMessages()
        self.chatText = ""
        self.count += 1
    }
}
