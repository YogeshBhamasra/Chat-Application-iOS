//
//  NewConversationViewModel.swift
//  Chat Application
//
//  Created by Yogesh Rao on 29/05/23.
//  Copyright © 2023 Yogesh Rao. All rights reserved.
//

import SwiftUI

class NewConversationViewModel: ObservableObject {
    @Published var users = [LocalUser]()
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
    }
    private func fetchAllUsers() {
        self.users = RealmManager()?.realm.objects(LocalUser.self).toArray() ?? []
    }
}
