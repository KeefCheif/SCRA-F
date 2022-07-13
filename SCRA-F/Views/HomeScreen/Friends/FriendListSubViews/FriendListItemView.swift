//
//  FriendListItemView.swift
//  SCRA-F
//
//  Created by KeefCheif on 7/12/22.
//

import SwiftUI

struct FriendListItemView: View {
    
    @ObservedObject var menu_manager: MenuViewModel
    
    @Environment(\.colorScheme) private var colorScheme
    
    var isFriendReq: Bool
    var displayUsername: String
    var id: String
    var picture: UIImage?
    
    var body: some View {
        
        HStack {
            
            if let picture = picture {
                Image(uiImage: picture)
                    .friendListProfilePic(darkMode: self.colorScheme == .dark)
            } else {
                Image(systemName: "person.circle")
                    .friendListProfilePic(darkMode: self.colorScheme == .dark)
            }
            
            Text(self.displayUsername)
                .bold()
                .foregroundColor(self.colorScheme == .dark ? .white : .black)
            
            Spacer()
            
            if self.isFriendReq {
                
        // - - - - - Accept Friend Req Button - - - - - //
                Button(action: {
                    self.menu_manager.respondFriendRequest(id: self.id, invitee_username: self.displayUsername, accept: true)
                }, label: {
                    Text("Accept")
                        .friendListButton(darkMode: self.colorScheme == .dark)
                })
                
        // - - - - - Reject Friend Req Button - - - - - //
                Button(action: {
                    self.menu_manager.respondFriendRequest(id: self.id, invitee_username: self.displayUsername, accept: false)
                }, label: {
                    Text("Reject")
                        .friendListButton(darkMode: self.colorScheme == .dark)
                })
            } else {
                
                Button(action: {
                    self.menu_manager.removeFriend(id: self.id, friend_username: self.displayUsername)
                }, label: {
                    Text("Unfriend")
                        .friendListButton(darkMode: self.colorScheme == .dark)
                })
            }
        }
    }
}
