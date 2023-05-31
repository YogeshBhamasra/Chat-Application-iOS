//
//  NewConversationView.swift
//  Chat Application
//
//  Created by Yogesh Rao on 29/05/23.
//  Copyright © 2023 Yogesh Rao. All rights reserved.
//

import SwiftUI
import SDWebImageSwiftUI

struct NewConversationView: View {
    let didSelectNewUser: (ChatUser) -> ()
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var vm = NewConversationViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                Text(vm.errorMessage)
                ForEach(vm.users) { user in
                    HStack {
                        Button {
                            presentationMode.wrappedValue.dismiss()
                            didSelectNewUser(user)
                        } label: {
                            WebImage(url: URL(string: user.profileImageUrl))
                                .resizable()
                                .frame(width: 50, height: 50)
                                .scaledToFit()
                                .clipped()
                                .cornerRadius(50)
                                .overlay(RoundedRectangle(cornerRadius: 50)
                                    .stroke(Color(uiColor: .label), lineWidth: 2))
                            Text(user.username)
                            Spacer()
                        }
                        .foregroundColor(Color(uiColor: .label))
                        
                    }
                    .padding(.horizontal)
                    
                    Divider()
                        .padding(.vertical, 8)
                }
                
            }
            .navigationTitle("New Message")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Text("Cancel")
                    }
                }
            }
        }
    }
}

struct NewConversationView_Previews: PreviewProvider {
    static var previews: some View {
        NewConversationView(didSelectNewUser: {user in})
    }
}
