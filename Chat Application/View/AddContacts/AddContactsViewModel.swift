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
//    let realm = RealmManager(obj: RecentMessages.Type)
    @Published var userConnected: String = ""
    func addContactToList(email: String) {
        var added = false
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
                                added = true
                                self?.saveContactsToFirebase(chatUser: user)
                                break
                            } else if docSnapshot == snapshot?.documents.last {
                                self?.userConnected = UserConnect.failure.rawValue
                                break
                            }
                    } catch {
                        debugPrint(error.localizedDescription)
                        self?.userConnected = error.localizedDescription
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self?.userConnected = ""
                }
            }
    }
    func saveContactsToFirebase(chatUser: ChatUser) {
        let manager = RealmManager(obj: User.self)
        let user = User(uid: chatUser.uid, email: chatUser.email, profileImageUrl: chatUser.profileImageUrl)
        manager.addData(object: user)
//        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {return}
//        let data: [String : Any] = [
//            UserData.email.value : chatUser.email,
//            UserData.uid.value: chatUser.uid,
//            UserData.userProfileImage.value: chatUser.profileImageUrl
//        ]
//        FirebaseManager.shared.firestore
//            .collection(Collections.userConnections.value)
//            .document(uid)
//            .collection(Collections.userCollection.value)
//            .document(chatUser.uid)
//            .setData(data) { error in
//                if let error {
//                    debugPrint(error)
//                    return
//                }
//            }
        let obj = manager.realm.objects(User.self)
        let array: [User] = obj.toArray()
        debugPrint(array)
    }
}
