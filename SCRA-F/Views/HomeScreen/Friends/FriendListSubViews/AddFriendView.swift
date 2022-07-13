//
//  AddFriendView.swift
//  SCRA-F
//
//  Created by KeefCheif on 7/11/22.
//

import SwiftUI

struct AddFriendView: View {
    
    @Environment(\.colorScheme) private var colorScheme
    
    @ObservedObject var menu_manager: MenuViewModel
    
    @State private var request_username: String = ""
    @State private var friend_invite_loading: Bool = false
    
    @State private var send_error: AccountError?
    
    var body: some View {
        
        VStack {
            
    // - - - - - Title - - - - - //
            Text("Add Friend")
                .bold().font(.title2).foregroundColor(self.colorScheme == .dark ? .white : .black)
            
            HStack {
                
    // - - - - - Username Input - - - - - //
                TextField("Username", text: self.$request_username)
                    .multilineTextAlignment(.center).padding(10).background(RoundedRectangle(cornerRadius: 20).foregroundColor(Color(UIColor.gray.withAlphaComponent(0.25))))
                
    // - - - - - Send Button - - - - - //
                Button(action: {
                    // Only try to send a friend request if it is NOT loading from a previous button press
                    if !self.friend_invite_loading {
                        self.friend_invite_loading = true
                        self.menu_manager.friendRequest(invitee_usernmae: self.request_username) { error in
                            if let error = error {
                                // Wait to unlock the loading flag until after the user has acknowledged the error/alert
                                self.send_error = error
                            } else {
                                // No error/alert, so unlock the loading flag
                                self.friend_invite_loading = false
                                self.request_username = ""
                            }
                        }
                    }
                }, label: {
                    HStack {
                        Text("Send")
                            .bold().foregroundColor(self.colorScheme == .dark ? .white : .black)
                        
                        if self.friend_invite_loading {
                            GenericLoadingView(size: 1.5)
                        } else {
                            Image(systemName: "paperplane.circle")
                                .resizable().scaledToFit().frame(width: 30).foregroundColor(self.colorScheme == .dark ? .white : .black)
                        }
                    }
                })
            }
            .padding([.top, .bottom], 10)
        }
        .alert("Friend Request Error", isPresented: .constant(self.send_error != nil), actions: {
            Button("Okay", role: .cancel, action: {
                self.send_error = nil
                self.friend_invite_loading = false
                self.request_username = ""
            })
        }, message: {
            if let error = self.send_error {
                Text(error.localizedDescription)
            }
        })
    }
}
