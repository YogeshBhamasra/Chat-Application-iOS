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

class ConversationsViewModel: ObservableObject {
    @Published var isUserLoggedOut = false
    @Published var errorMessage = ""
    @Published var chatUser: ChatUser?
    @Published var recentMessages = [RecentMessages]()
    @Published var firestoreListener: ListenerRegistration?
    @Published var profileImage: UIImage?
    
    init() {
        DispatchQueue.main.async {
            self.isUserLoggedOut = FirebaseManager.shared.auth.currentUser?.uid == nil
        }
        fetchCurrentUser()
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
        let image = ImageManager.shared.images.getImage(key: url)
        debugPrint(image)
    }
    func fetchCurrentUser() {
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
                if let bool = documentsSnapshot?.documents.first(where: { snapshot in
                    snapshot.documentID == uid
                }) {
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
    private func fetchRecentMessages() {
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
                
                querySnapshot?.documentChanges.forEach({ change in
                    let id = change.document.documentID
                    if let index = self.recentMessages.firstIndex(where: { message in
                        message.id == id
                    }){
                        self.recentMessages.remove(at: index)
                    }
                    do {
                        let message = try change.document.data(as: RecentMessages.self)
                        self.recentMessages.insert(message, at: 0)
                    } catch {
                        self.errorMessage = "Failed to decode: \(error.localizedDescription)"
                    }
                })
            }
    }
    func deleteChat(message: RecentMessages) {
        guard let uid = FirebaseManager.shared.currentUser?.uid else {return}
        let fromId = message.fromId == uid ? message.toId : message.fromId
        debugPrint(fromId)
        debugPrint(uid)
        let recentDocRef = FirebaseManager.shared.firestore
            .collection(Collections.recentMessages.value)
            .document(uid)
            .collection(Collections.userMessages.value)
            .document(fromId)
        let chatMsgRef = FirebaseManager.shared.firestore
            .collection(Collections.userMessages.value)
            .document(uid)
            .collection(fromId)
        recentDocRef.getDocument { [weak self] doc, error in
            doc?.reference.delete()
            
            self?.fetchRecentMessages()
        }
        chatMsgRef.getDocuments { snapshot, error in
            snapshot?.documents.forEach({ doc in
                doc.reference.delete()
            })
        }
    }
}
