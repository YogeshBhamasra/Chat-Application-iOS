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
    init() {
        DispatchQueue.main.async {
            self.isUserLoggedOut = FirebaseManager.shared.auth.currentUser?.uid == nil
        }
        fetchCurrentUser()
        fetchRecentMessages()
    }
    
    func fetchCurrentUser() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            self.errorMessage = "Could not find firebase uid"
            return
        }
        self.errorMessage = uid
        FirebaseManager.shared.firestore
            .collection(Collections.userCollection.value)
            .document(uid).getDocument { [weak self] snapshot, error in
                if let error {
                    self?.errorMessage = "failed to fetch users: \(error)"
                    return
                }
                do {
                    
                    let user = try snapshot?.data(as: ChatUser.self)
                    self?.chatUser = user
                    FirebaseManager.shared.currentUser = self?.chatUser
                } catch {
                    self?.errorMessage = "Failed to decode: \(error.localizedDescription)"
                }
            }
        fetchRecentMessages()
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
        self.recentMessages.removeAll()
        FirebaseManager.shared.firestore
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
}
