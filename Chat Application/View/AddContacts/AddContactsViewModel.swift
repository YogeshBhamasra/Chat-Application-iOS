//
//  AddContactsViewModel.swift
//  Chat Application
//
//  Created by Yogesh Rao on 05/06/23.
//  Copyright © 2023 Yogesh Rao. All rights reserved.
//

import SwiftUI
import RealmSwift
enum UserConnect: String {
    case success = "User Added Successfully"
    case failure = "No such user found"
}
class AddContactsViewModel: ObservableObject {
    @Published var userConnected: String = ""
    @Published var showAlert = false
    func addContactToList(email: String) {
        guard email != "" else {return}
        if email == FirebaseManager.shared.auth.currentUser?.email {
            return
        }
        FirebaseManager.shared.firestore
            .collection(Collections.userCollection.value)
            .getDocuments { [weak self] snapshot, error in
                if let error {
                    debugPrint(error.localizedDescription)
                    return
                }
                for docSnapshot in snapshot?.documents ?? [] {
                    do {
                            let user = try docSnapshot.data(as: ChatUser.self)
                            if user.email == email {
                                self?.userConnected = UserConnect.success.rawValue
                                self?.saveContactsToFirebase(chatUser: user)
                                self?.showAlert = true
                                break
                            } else if docSnapshot == snapshot?.documents.last {
                                self?.userConnected = UserConnect.failure.rawValue
                                self?.showAlert = true
                                break
                            }
                    } catch {
                        debugPrint(error.localizedDescription)
                        self?.userConnected = error.localizedDescription
                        self?.showAlert = true
                    }
                }
            }
    }
    func saveContactsToFirebase(chatUser: ChatUser) {
        let manager = RealmManager()
        let user = LocalUser(uid: chatUser.uid, email: chatUser.email, profileImageUrl: chatUser.profileImageUrl)
        manager?.addData(object: user)
    }
}
