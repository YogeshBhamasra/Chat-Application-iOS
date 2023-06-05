//
//  NewConversationViewModel.swift
//  Chat Application
//
//  Created by Yogesh Rao on 29/05/23.
//  Copyright © 2023 Yogesh Rao. All rights reserved.
//

import SwiftUI

class NewConversationViewModel: ObservableObject {
    @Published var users = [User]()
    @Published var errorMessage = ""
    @Published var images : [String: UIImage] = [:]
    init() {
        fetchAllUsers()
    }
    func downloadImage(url: String) {
        ImageManager.shared.downloadImage(urlString: url) {[weak self] result in
            switch result {
            case .success(let success):
                DispatchQueue.main.async {
                    self?.images[url] = success
                }
            case .failure(let failure):
                debugPrint(failure)
            }
        }
        let image = ImageManager.shared.images.getImage(key: url)
        debugPrint(image)
    }
//    private func firebaseListener() {
//        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {return}
//        FirebaseManager.shared.firestore
//            .collection(Collections.userConnections.value)
//            .document(uid)
//            .collection(Collections.userCollection.value)
//            .getDocuments { [weak self] documentsSnapshot, error in
//                if let error {
//                    self?.errorMessage = "Failed to fetch users: \(error)"
//                    debugPrint("Failed to fetch users: \(error)")
//                    return
//                }
//                documentsSnapshot?.documents.forEach({ [weak self] snapshot in
//                    let data = snapshot.data()
//                    do {
//                        let user = try snapshot.data(as: ChatUser.self)
//                        if user.uid != FirebaseManager.shared.auth.currentUser?.uid {
//                            self?.downloadImage(url: user.profileImageUrl)
//                            self?.users.append(user)
//                        }
//                    } catch {
//                        self?.errorMessage = "Failed to decode: \(error.localizedDescription)"
//                    }
//                })
//            }
//    }
    private func fetchAllUsers() {
        self.users = RealmManager().realm.objects(User.self).toArray()
    }
}

