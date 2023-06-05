//
//  ChatView.swift
//  Chat Application
//
//  Created by Yogesh Rao on 30/05/23.
//  Copyright © 2023 Yogesh Rao. All rights reserved.
//

import SwiftUI
import SDWebImageSwiftUI

struct ChatView: View {
    let emptyScrollidentifier = "Empty"
    @State private var showImagePicker = false
    @ObservedObject var vm: ChatViewModel

    init(vm: ChatViewModel) {
        self.vm = vm
        //Use this if NavigationBarTitle is with Large Font
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.label]

        //Use this if NavigationBarTitle is with displayMode = .inline
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.label]
        
        UINavigationBar.appearance().backgroundColor = .white
    }
    var body: some View {
        ZStack {
            chatMessages()
            Text(vm.errorMessages)
        }
        .onDisappear{
            vm.firestoreListener?.remove()
        }
        .navigationTitle(vm.chatUser?.username ?? "")
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $showImagePicker, onDismiss: nil) {
            ImagePicker(image: $vm.image)
                .onDisappear {
                    vm.handleImages()
                }
        }
    }
    private func chatMessagesView(message: Message) -> some View {
        VStack {
            if message.from == FirebaseManager.shared.auth.currentUser?.uid {
                HStack {
                    Spacer()
                    
                        if let text = message.text  {
                            HStack {
                                Text(text)
                                    .foregroundColor(.white)
                            }
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(8)
                        } else if let image = message.imageURL {
                            if image != "" {
                                HStack {
                                WebImage(url: URL(string: image))
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 200, height: 100)
                                    .cornerRadius(8)
                            }
                            }
                        }
                    
                }
            } else {
                HStack {
                    if let text = message.text  {
                        HStack {
                            Text(text)
                                .foregroundColor(.black)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                    } else if let image = message.imageURL {
                        if image != "" {
                            HStack {
                            WebImage(url: URL(string: image))
                                .resizable()
                                .scaledToFill()
                                .frame(width: 200, height: 100)
                                .cornerRadius(8)
                        }
                        }
                    }
                    
                    Spacer()
                }
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
    private func chatMessages() -> some View {
        VStack {
            ScrollView {
                ScrollViewReader { proxy in
                    VStack {
                        ForEach(vm.chatMessages) { message in
                            chatMessagesView(message: message)
                        }
                        HStack {
                            Spacer()
                        }
                        .id(self.emptyScrollidentifier)
                    }
                    .onReceive(vm.$count) { _ in
                        withAnimation(.easeOut(duration: 0.5)) {
                            proxy.scrollTo(self.emptyScrollidentifier, anchor: .bottom)
                        }
                    }
                }
            }
            .background(Color(.init(white: 0.95, alpha: 1)))
            .safeAreaInset(edge: .bottom) {
                messagesBottomBar()
                    .background(Color(uiColor: .systemBackground).ignoresSafeArea())
            }
            
        }
    }
    private func messagesBottomBar() -> some View {
        HStack(spacing: 16) {
            Button {
                showImagePicker.toggle()
            } label: {
                Image(systemName: "photo.on.rectangle")
                    .font(.system(size: 24))
                    .foregroundColor(Color(uiColor: .darkGray))
            }
                
            ZStack {
                DescriptionPlaceholder()
                TextEditor(text: $vm.chatText)
                    .opacity(vm.chatText.isEmpty ? 0.5 : 1)
            }
            .frame(height: 40)
            Button {
                if !vm.chatText.isEmpty {
                    vm.sendMessage()
                }
            } label: {
                Text("Send")
                    .foregroundColor(.white)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
            }
            .background(Color.blue)
            .cornerRadius(5)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}
private struct DescriptionPlaceholder: View {
    var body: some View {
        HStack {
            Text("Enter New Message")
                .foregroundColor(Color(.gray))
                .font(.system(size: 17))
                .padding(.leading, 5)
                .padding(.top, -4)
            Spacer()
        }
    }
}
struct ChatView_Previews: PreviewProvider {
    static func getTestUser() -> User {
        User(uid: "Ts4HsIKJkhfOTbXGyx8lfyqmrZ52", email: "test@email.com", profileImageUrl: "")
    }
    
    static var previews: some View {
        
        NavigationView {
            ChatView(vm: .init(chatUser: getTestUser()))
        }
    }
}
