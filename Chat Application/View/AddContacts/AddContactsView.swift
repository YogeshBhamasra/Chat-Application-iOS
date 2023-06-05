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
    var body: some View {
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
                }
                
                .padding([.top, .horizontal], 20)
                Spacer()
                sendButton()
            }
            
            .overlay(alignment: .center) {
                if emailId != "" {
                    Text(vm.userConnected)
                }
            }
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
            presentationMode.wrappedValue.dismiss()
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
