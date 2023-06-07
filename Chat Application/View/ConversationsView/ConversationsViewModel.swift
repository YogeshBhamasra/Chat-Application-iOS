//
//  ConversationsViewModel.swift
//  Chat Application
//
//  Created by Yogesh Rao on 29/05/23.
//  Copyright © 2023 Yogesh Rao. All rights reserved.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift
import RealmSwift

class ConversationsViewModel: ObservableObject {
    @Published var isUserLoggedOut = false
    @Published var errorMessage = ""
    @Published var chatUser: ChatUser?
    @Published var recentMessages = [RecentMessageLocal]()
    @Published var firestoreListener: ListenerRegistration?
    @Published var profileImage: UIImage?
    var notificationToken: NotificationToken?
    init() {
        fetchCurrentUser()
        firebaseObserver()
        fetchRecentMessages()
    }
    func downloadImage(url: String) {
        ImageManager.shared.downloadImage(urlString: url) {[weak self] result in
            switch result {
            case .success(let success):
                DispatchQueue.main.async {
                    self?.profileImage = success
                }
            case .failure(let failure):
                debugPrint(failure)
            }
        }
    }
    func fetchCurrentUser() {
        DispatchQueue.main.async {
            self.isUserLoggedOut = FirebaseManager.shared.auth.currentUser?.uid == nil
        }
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            self.errorMessage = "Could not find firebase uid"
            return
        }
        
        FirebaseManager.shared.firestore
            .collection(Collections.userCollection.value)
            .document(uid).getDocument { [weak self] snapshot, error in
                if let error {
                    self?.errorMessage = "failed to fetch users: \(error)"
                    return
                }
                do {
                    self?.chatUser = try snapshot?.data(as: ChatUser.self)
                    FirebaseManager.shared.currentUser = self?.chatUser
                    self?.downloadImage(url: self?.chatUser?.profileImageUrl ?? "")
                } catch {
                    self?.errorMessage = "Failed to decode: \(error.localizedDescription)"
                }
            }
        fetchRecentMessages()
    }
    func checkUser() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            handleSignOut()
            return
        }
        FirebaseManager.shared.firestore.collection(Collections.userCollection.value)
            .getDocuments { [weak self] documentsSnapshot, error in
                if let error {
                    self?.errorMessage = "Failed to fetch users: \(error)"
                    debugPrint("Failed to fetch users: \(error)")
                    return
                }
                if documentsSnapshot?.documents.first(where: { snapshot in
                    snapshot.documentID == uid
                }) != nil {
                    return
                } else {
                    self?.handleSignOut()
                }
            }
    }
    func handleSignOut() {
        isUserLoggedOut.toggle()
        try? FirebaseManager.shared.auth.signOut()
    }
    func firebaseObserver() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            self.errorMessage = "Could not find user id"
            return
        }
        firestoreListener?.remove()
        self.recentMessages.removeAll()
        firestoreListener = FirebaseManager.shared.firestore
            .collection(Collections.recentMessages.value)
            .document(uid)
            .collection(Collections.userMessages.value)
            .order(by: MessagesData.chatTimestamp.value)
            .addSnapshotListener { querySnapshot, error in
                if let error {
                    self.errorMessage = "Failed to get recent messages: \(error.localizedDescription)"
                    return
                }
                
                querySnapshot?.documents.forEach({ [weak self] documentSnapshot in
                    do {
                        let message = try documentSnapshot.data(as: RecentMessages.self)
                        if let previousMessage = self?.recentMessages.first(where: { msg in
                            msg.email == message.email
                        }) {
                            RealmManager()?.deleteData(object: previousMessage)
                        }
                            let recentMessage = RecentMessageLocal(message: message)
                            RealmManager()?.addData(object: recentMessage)
                        documentSnapshot.reference.delete()
                    } catch {
                        self?.errorMessage = "Failed to decode: \(error.localizedDescription)"
                    }
                })
            }
    }
    private func fetchRecentMessages() {
        notificationToken = nil
        notificationToken = RealmManager()?.realm.objects(RecentMessageLocal.self).observe({ [weak self] change in
            switch change {
                
            case .initial(let messages):
                self?.recentMessages = messages.toArray()
                self?.recentMessages.sort(by: {
                    $0.timestamp > $1.timestamp
                })
            case .update(let messages, deletions: _, insertions: _, modifications: _):
                self?.recentMessages = messages.toArray()
            case .error(let error):
                self?.errorMessage = error.localizedDescription
            }
        })
    }
    func deleteChat(message: RecentMessageLocal) {
        let toId = message.toId
        let fromId = message.fromId
        let currentRecentMessages: [RecentMessageLocal] = RealmManager()?.realm.objects(RecentMessageLocal.self).toArray() ?? []
        let chatMessages: [UserMessage] = RealmManager()?.realm.objects(UserMessage.self).toArray() ?? []
        for currentRecentMessage in currentRecentMessages where currentRecentMessage == message {
            RealmManager()?.deleteData(object: currentRecentMessage)
        }
        for chatMessage in chatMessages where chatMessage.withUser == fromId || chatMessage.withUser == toId {
            RealmManager()?.deleteData(object: chatMessage)
        }
    }
}
