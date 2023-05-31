//
//  ConversationsView.swift
//  Chat Application
//
//  Created by Yogesh Rao on 29/05/23.
//  Copyright © 2023 Yogesh Rao. All rights reserved.
//

import SwiftUI
import SDWebImageSwiftUI

struct ConversationsView: View {
    @State var showLogOutOptions = false
    @State var showNewMessageScreen = false
    @State var navigateToChatView = false
    @State var chatUser: ChatUser?
    @ObservedObject private var vm = ConversationsViewModel()
    var body: some View {
        NavigationView {
            VStack {
                customNavigationBar()
                messages()
                NavigationLink(isActive: $navigateToChatView) {
                    ChatView(chatUser: self.chatUser)
                } label: {
                    Text("")
                }

            }
            .overlay(alignment: .bottom, content: {
                newMessageButton()
            })
            .navigationBarHidden(true)
        }
        
    }
    
    private func customNavigationBar() -> some View {
        HStack {
            WebImage(url: URL(string: vm.chatUser?.profileImageUrl ?? ""))
                .resizable()
                .scaledToFill()
                .frame(width: 50, height: 50)
                .clipped()
                .cornerRadius(50)
                .overlay(RoundedRectangle(cornerRadius: 44)
                    .stroke(Color(uiColor: .label), lineWidth: 1))
                .shadow(radius: 5)
            
            VStack(alignment: .leading) {
                Text("\(vm.chatUser?.username ?? "")")
                    .font(.system(size: 24, weight: .bold))
                HStack {
                    Circle()
                        .foregroundColor(.green)
                        .frame(width: 14, height: 14)
                    
                    Text("online")
                        .font(.system(size: 12))
                        .foregroundColor(Color(uiColor: .darkGray))
                }
            }
            Spacer()
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
            .init(title: Text("Settings"), message: Text("What doo you want to do?"), buttons: [
                .destructive(Text("Sign Out"), action: {
                    vm.handleSignOut()
                }),
                .cancel()
            ])
        }
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
                NavigationLink {
                    ChatView(chatUser: ChatUser(uid: recentMessage.toId, email: recentMessage.email, profileImageUrl: recentMessage.profileImageUrl))
                } label: {
                    HStack(spacing: 16) {
                        if recentMessage.profileImageUrl == "" {
                            Image(systemName: "person.fill")
                                .font(.system(size: 32))
                                .padding(8)
                                .overlay(RoundedRectangle(cornerRadius: 44)
                                    .stroke(Color(uiColor: .label), lineWidth: 1))
                        } else {
                            WebImage(url: URL(string: recentMessage.profileImageUrl))
                                .resizable()
                                .scaledToFill()
                                .frame(width: 64, height: 64)
                                .clipped()
                                .cornerRadius(64)
                                .overlay(RoundedRectangle(cornerRadius: 44)
                                    .stroke(Color(uiColor: .label), lineWidth: 1))
                                .shadow(radius: 5)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text(recentMessage.username)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(Color(uiColor: .label))
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
                }
                Divider()
                    .padding(.vertical,8)
                
            }
            .padding(.horizontal)
        }
        .padding(.bottom, 50)
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
            })
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
