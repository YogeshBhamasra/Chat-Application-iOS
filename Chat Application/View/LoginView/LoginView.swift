//
//  LoginView.swift
//  Chat Application
//
//  Created by Yogesh Rao on 29/05/23.
//  Copyright © 2023 Yogesh Rao. All rights reserved.
//

import SwiftUI
import Firebase

struct LoginView: View {
    let didCompleteLogin: () -> ()
    
    @State private var isLoginMode = true
    @State private var email = ""
    @State private var password = ""
    @State private var loginStatusMessage = ""
    @State private var showImagePicker = false
    @State private var profileImage: UIImage?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    Picker(selection: $isLoginMode) {
                        Text("Login")
                            .tag(true)
                        Text("Create Account")
                            .tag(false)
                    } label: {
                        Text("Choose Account Mode")
                    }
                    .onChange(of: isLoginMode, perform: { _ in
                        loginStatusMessage = ""
                        email = ""
                        password = ""
                    })
                    .pickerStyle(.segmented)
                    .padding()

                    if !isLoginMode {
                        Button {
                            showImagePicker.toggle()
                        } label: {
                            VStack {
                                if let image = self.profileImage {
                                    Image(uiImage: image)
                                        .resizable()
                                        .frame(width: 128, height: 128)
                                        .scaledToFill()
                                        .cornerRadius(64)
                                } else {
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 64))
                                        .padding()
                                        .foregroundColor(Color(uiColor: .label))
                                }
                            }
                            .overlay(RoundedRectangle(cornerRadius: 64)
                                .stroke(Color.black, lineWidth: 3))
                            
                        }
                        .padding()
                    }
                    
                    Group {
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                        
                        SecureField("Password", text: $password)
                    }
                    .padding(12)
                    .background(Color.white)
                    
                    Button {
                        handleLoginAction()
                    } label: {
                        HStack {
                            Spacer()
                            Text(isLoginMode ? "Log In" : "Create Account")
                                .padding(.vertical, 10)
                                .foregroundColor(.white)
                                .font(.system(size: 15, weight: .semibold))
                            Spacer()
                        }
                        .background(Color.blue)
                    }
                    Text(self.loginStatusMessage)
                        .foregroundColor(.red)
                }
                .padding()
                }
            
                
            .navigationTitle(isLoginMode ? "Log In" : "Create Account")
            .background(Color(.init(white: 0, alpha: 0.05))
                .ignoresSafeArea())
        }
        .navigationViewStyle(.stack)
        .fullScreenCover(isPresented: $showImagePicker, onDismiss: nil) {
            ImagePicker(image: $profileImage)
        }
    }
    private func storeUserInformation (imageProfileURL: URL) {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {return}
        
        let userData = [UserData.email.value : self.email, UserData.uid.value: uid, UserData.userProfileImage.value: imageProfileURL.absoluteString]
        FirebaseManager.shared.firestore.collection(Collections.userCollection.value)
            .document(uid).setData(userData) { error in
                if let error {
                    self.loginStatusMessage = "\(error)"
                    return
                }
                self.loginStatusMessage = "Success"
                self.didCompleteLogin()
            }
    }
    private func handleImages() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {return}
        guard let imageData = self.profileImage?.jpegData(compressionQuality: 0.5) else {return}
        let ref = FirebaseManager.shared.storage.reference(withPath: uid)
        ref.putData(imageData) { metadata, error in
            if let error {
                self.loginStatusMessage = "Failed to push image in Storage: \(error)"
                return
            }
            ref.downloadURL { url, error in
                if let error {
                    self.loginStatusMessage = "Failed to retrieve downloadURL: \(error)"
                    return
                }
                self.loginStatusMessage = "Successfully stored image with url: \(url?.absoluteString ?? "")"
                guard let url else {return}
                self.storeUserInformation(imageProfileURL: url)
            }
        }
    }
    private func handleLoginAction() {
        if isLoginMode {
            signIn()
        } else {
            registerAccount()
        }
    }
    private func signIn() {
        FirebaseManager.shared.auth.signIn(withEmail: email.lowercased(), password: password) { result,error in
            if let error {
                debugPrint(error)
                self.loginStatusMessage = "Failed to LogIn: \(error)"
                return
            }
            self.loginStatusMessage = "Successfully Logged in as: \(result?.user.uid ?? "")"
            self.didCompleteLogin()
        }
    }
    private func registerAccount() {
        if self.profileImage == nil {
            self.loginStatusMessage = "You must select a profile Image"
            return
        }
        FirebaseManager.shared.auth.createUser(withEmail: email.lowercased(), password: password) { result,error in
            if let error {
                debugPrint(error)
                self.loginStatusMessage = "Failed to register user: \(error)"
                return
            }
            self.loginStatusMessage = "Successfully created user: \(result?.user.uid ?? "")"
            self.handleImages()
            debugPrint(result?.user.uid ?? "")
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(didCompleteLogin: {})
    }
}
