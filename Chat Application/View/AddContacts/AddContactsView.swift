//
//  AddContactsView.swift
//  Chat Application
//
//  Created by Yogesh Rao on 05/06/23.
//  Copyright © 2023 Yogesh Rao. All rights reserved.
//

import SwiftUI

struct AddContactsView: View {
    @State var emailId = ""
    @ObservedObject var vm = AddContactsViewModel()
    @Environment(\.presentationMode) var presentationMode
    @FocusState private var focused: Bool
    var body:some View {
        NavigationView {
            VStack {
                HStack {
                    Text("Email Id:")
                    TextField("Enter email to connect", text: $emailId)
                        .textFieldStyle(.plain)
                        .textInputAutocapitalization(.never)
                        .frame(width: nil, height: 50)
                        .padding(.horizontal)
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.gray))
                        .focused($focused)
                }
                
                .padding([.top, .horizontal], 20)
                Spacer()
                sendButton()
            }
            .alert(isPresented: $vm.showAlert, content: {
                Alert(title: Text("Alert"), message: Text(vm.userConnected),dismissButton: .default(Text("OK"), action: {
                    presentationMode.wrappedValue.dismiss()
                }))
            })
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
    func sendButton() -> some View {
        Button {
            vm.addContactToList(email: emailId)
            focused = false
        } label: {
            Spacer()
            Text("Add Contact".uppercased())
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.horizontal)
                .padding(.vertical)
            Spacer()
        }
        .cornerRadius(12)
        .background(Color(uiColor: .label))
        .frame(width: nil, height: 50, alignment: .bottom)
    }
}

struct AddContactsView_Previews: PreviewProvider {
    static var previews: some View {
        AddContactsView()
    }
}
