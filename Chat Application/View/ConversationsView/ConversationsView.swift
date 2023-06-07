//
//  ConversationsView.swift
//  Chat Application
//
//  Created by Yogesh Rao on 29/05/23.
//  Copyright © 2023 Yogesh Rao. All rights reserved.
//

import SwiftUI
import SDWebImageSwiftUI
import Nuke

struct ConversationsView: View {
    @State var showLogOutOptions = false
    @State var showDeleteOptions = false
    @State var showNewMessageScreen = false
    @State var navigateToChatView = false
    @State var showConnectUserScreen = false
    @State var chatUser: LocalUser?
    @ObservedObject private var vm = ConversationsViewModel()
    private var chatViewModel = ChatViewModel(chatUser: nil)
    var body: some View {
        NavigationView {
            VStack {
                customNavigationBar()
                messages()
                NavigationLink("", isActive: $navigateToChatView) {
                    ChatView(vm: chatViewModel)
                }
            }
            .overlay(alignment: .bottom, content: {
                newMessageButton()
            })
            .navigationBarHidden(true)
        }
        
    }
    
    private func customNavigationBar() -> some View {
        return HStack(spacing: 16) {
            if let image = ImageManager.shared.images.getImage(key: vm.chatUser?.profileImageUrl ?? "") {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipped()
                    .cornerRadius(50)
                    .overlay(RoundedRectangle(cornerRadius: 44)
                        .stroke(Color(uiColor: .label), lineWidth: 1))
                    .shadow(radius: 5)
            } else {
                WebImage(url: URL(string: vm.chatUser?.profileImageUrl ?? ""))
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipped()
                    .cornerRadius(50)
                    .overlay(RoundedRectangle(cornerRadius: 44)
                        .stroke(Color(uiColor: .label), lineWidth: 1))
                    .shadow(radius: 5)
                    .onAppear {
                        SDImageCache.shared.clearMemory()
                    }
            }
            VStack(alignment: .leading, spacing: 4) {
                Text("\(vm.chatUser?.username ?? "")")
                    .font(.system(size: 24, weight: .bold))
                HStack {
                    Circle()
                        .foregroundColor(.green)
                        .frame(width: 14, height: 14)
                    
                    Text("online")
                        .font(.system(size: 12))
                        .foregroundColor(Color(uiColor: .lightGray))
                }
            }
            Spacer()
            Button {
                showConnectUserScreen.toggle()
            } label: {
                Image(systemName: "person.badge.plus")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(uiColor: .label))
            }
            Button {
                showLogOutOptions.toggle()
            } label: {
                Image(systemName: "gear")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(uiColor: .label))
            }
        }
        .padding()
        .actionSheet(isPresented: $showLogOutOptions) {
            .init(title: Text("Settings"), message: Text("What do you want to do?"), buttons: [
                .destructive(Text("Sign Out"), action: {
                    vm.handleSignOut()
                }),
                .cancel()
            ])
        }
        .onAppear {
            vm.checkUser()
        }
        .fullScreenCover(isPresented: $showConnectUserScreen, content: {
            AddContactsView()
        })
        .fullScreenCover(isPresented: $vm.isUserLoggedOut) {
            LoginView(didCompleteLogin: {
                self.vm.isUserLoggedOut = false
                self.vm.fetchCurrentUser()
            })
        }
    }
    private func messages() -> some View {
        ScrollView {
            ForEach(vm.recentMessages) { recentMessage in
                VStack {
                    Button {
                        
                    } label: {
                        HStack(spacing: 16) {
                            if let image = ImageManager.shared.images.getImage(key: recentMessage.profileImageUrl) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 64, height: 64)
                                    .clipped()
                                    .cornerRadius(64)
                                    .overlay(RoundedRectangle(cornerRadius: 64).stroke(Color(uiColor: .label), lineWidth: 1))
                                    .shadow(radius: 5)
                            } else {
                                WebImage(url: URL(string: recentMessage.profileImageUrl))
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 64, height: 64)
                                    .clipped()
                                    .cornerRadius(64)
                                    .overlay(RoundedRectangle(cornerRadius: 64).stroke(Color(uiColor: .label), lineWidth: 1))
                                    .shadow(radius: 5)
                            }
                            VStack(alignment: .leading, spacing: 8) {
                                Text(recentMessage.username)
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(Color(uiColor: .label))
                                    .multilineTextAlignment(.leading)
                                Text(recentMessage.text)
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(uiColor: .lightGray))
                                    .multilineTextAlignment(.leading)
                            }
                            Spacer()
                            Text(recentMessage.timeAgo)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color(uiColor: .label))
                        }
                        
                        .onTapGesture {
                            let uid = FirebaseManager.shared.auth.currentUser?.uid == recentMessage.fromId ? recentMessage.toId : recentMessage.fromId
                            self.chatUser = .init(uid: uid, email: recentMessage.email, profileImageUrl: recentMessage.profileImageUrl)
                            self.chatViewModel.chatUser = self.chatUser
                            self.chatViewModel.firebaseObserver()
                            self.chatViewModel.fetchMessages()
                            self.navigateToChatView.toggle()
                        }
                        .onLongPressGesture {
                            showDeleteOptions.toggle()
                        }
                        .confirmationDialog("Delete Chat", isPresented: $showDeleteOptions) {
                            Button(role: .destructive) {
                                vm.deleteChat(message: recentMessage)
                            } label: {
                                Text("Delete")
                            }
                            
                        }
                    }
                    }
                Divider()
                    .padding(.vertical, 8)
            }
            .onDelete(perform: deleteChats)
            .padding(.horizontal)
        }
        .padding(.bottom,50)
    }
    private func newMessageButton() -> some View {
        Button {
            showNewMessageScreen.toggle()
        } label: {
            HStack {
                Spacer()
                Text("+ New Message")
                    .font(.system(size: 16, weight: .bold))
                Spacer()
            }
            .foregroundColor(.white)
            .padding(.vertical)
            .background(Color.blue)
            .cornerRadius(32)
            .padding(.horizontal)
            .shadow(radius: 15)
        }
        .fullScreenCover(isPresented: $showNewMessageScreen) {
            NewConversationView(didSelectNewUser: {user in
                debugPrint(user.email)
                self.navigateToChatView.toggle()
                self.chatUser = user
                self.chatViewModel.chatUser = user
                self.chatViewModel.fetchMessages()
            })
        }
    }
    private func deleteChats(at offsets: IndexSet) {
        withAnimation {
            offsets.map {
                vm.recentMessages[$0]
            }.forEach { message in
                vm.deleteChat(message: message)
            }
        }
    }
}

struct ConversationsView_Previews: PreviewProvider {
    static var previews: some View {
        ConversationsView()
            .preferredColorScheme(.dark)
        ConversationsView()
    }
}
