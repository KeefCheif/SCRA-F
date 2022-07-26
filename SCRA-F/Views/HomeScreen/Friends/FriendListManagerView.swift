//
//  FriendListManagerView.swift
//  SCRA-F
//
//  Created by KeefCheif on 6/23/22.
//

import SwiftUI

struct FriendListManagerView: View {
    
    @Environment(\.colorScheme) private var colorScheme
    
    @ObservedObject var menu_manager: MenuViewModel
    
    @State private var request_username: String = ""
    @State private var friend_invite_loading: Bool = false
    
    var body: some View {
        
        VStack {
    // - - - - - Friend Request Button - - - - - //
            AddFriendView(menu_manager: menu_manager)
            
            Divider()
            
    // - - - - - List Friends & Friend Requests - - - - - //
            
            ForEach(0..<self.menu_manager.friends_model.friendReqs.count + self.menu_manager.friends_model.friends.count, id: \.self) { index in
                
                if index < self.menu_manager.friends_model.friendReqs.count {
                    FriendListItemView(menu_manager: self.menu_manager, isFriendReq: true, displayUsername: self.menu_manager.friends_model.friendReqs[index].displayUsername, id: self.menu_manager.friends_model.friendReqs[index].id, picture: self.menu_manager.friends_model.friendReqs[index].profile_picture)
                } else {
                    FriendListItemView(menu_manager: self.menu_manager, isFriendReq: false, displayUsername: self.menu_manager.friends_model.friends[index - self.menu_manager.friends_model.friendReqs.count].displayUsername, id: self.menu_manager.friends_model.friends[index - self.menu_manager.friends_model.friendReqs.count].id, picture: self.menu_manager.friends_model.friends[index - self.menu_manager.friends_model.friendReqs.count].profile_picture)
                }
            }
            
            Spacer()
        }
        .padding(20)
        .frame(maxWidth: .infinity)
    }
}

struct FriendListManagerView_Previews: PreviewProvider {
    static var previews: some View {
        FriendListManagerView(menu_manager: MenuViewModel())
    }
}

extension Image {
    func friendListProfilePic(darkMode: Bool) -> some View {
        self.resizable().scaledToFill().frame(width: 60, height: 60).clipShape(Circle())
    }
}

extension Text {
    func friendListButton(darkMode: Bool) -> some View {
        self.foregroundColor(darkMode ? .white : .black).bold().padding(10).overlay(RoundedRectangle(cornerRadius: 20).stroke(darkMode ? .white : .black, lineWidth: 2))
    }
}
