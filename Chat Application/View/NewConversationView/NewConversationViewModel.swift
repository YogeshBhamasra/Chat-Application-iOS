//
//  NewConversationViewModel.swift
//  Chat Application
//
//  Created by Yogesh Rao on 29/05/23.
//  Copyright © 2023 Yogesh Rao. All rights reserved.
//

import SwiftUI

class NewConversationViewModel: ObservableObject {
    @Published var users = [ChatUser]()
    @Published var errorMessage = ""
    init() {
        fetchAllUsers()
    }
    private func fetchAllUsers() {
        FirebaseManager.shared.firestore.collection(Collections.userCollection.value)
            .getDocuments { documentsSnapshot, error in
                if let error {
                    self.errorMessage = "Failed to fetch users: \(error)"
                    debugPrint("Failed to fetch users: \(error)")
                    return
                }
                documentsSnapshot?.documents.forEach({ snapshot in
                    let data = snapshot.data()
                    do {
                        let user = try snapshot.data(as: ChatUser.self)
                        if user.uid != FirebaseManager.shared.auth.currentUser?.uid {
                            self.users.append(user)
                        }
                    } catch {
                        self.errorMessage = "Failed to decode: \(error.localizedDescription)"
                    }
                })
            }
    }
}

