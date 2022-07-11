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
            
    // - - - - - Send Friend Request Button - - - - - //
            Text("Add Friend")
                .bold().foregroundColor(self.colorScheme == .dark ? .white : .black).font(.title2)
            
            HStack {
                
                TextField("Username", text: self.$request_username)
                    .multilineTextAlignment(.center).padding(10).background(RoundedRectangle(cornerRadius: 20).foregroundColor(Color(UIColor.gray.withAlphaComponent(0.25))))
                
                Button(action: {
                    if !self.friend_invite_loading {
                        self.friend_invite_loading = true
                        self.menu_manager.friendRequest(invitee_usernmae: self.request_username) {
                            self.friend_invite_loading = false
                            self.request_username = ""
                        }
                    }
                }, label: {
                    HStack {
                        Text("Send")
                            .bold().foregroundColor(self.colorScheme == .dark ? .white : .black)
                        
                        if self.friend_invite_loading {
                            GenericLoadingView()
                                .frame(maxWidth: 10)
                        } else {
                            Image(systemName: "paperplane.circle")
                                .resizable().scaledToFit().frame(width: 30).foregroundColor(self.colorScheme == .dark ? .white : .black)
                        }
                    }
                })
            }
            .padding([.bottom, .top], 10)
            
            Divider()
            
    // - - - - - List Friends & Friend Requests - - - - - //
            ForEach(0..<self.menu_manager.friend_model.friendReqs.count + self.menu_manager.friend_model.friends.count, id: \.self) { index in
                
                if index < self.menu_manager.friend_model.friendReqs.count {
                
                    FriendListItemView(menu_manager: self.menu_manager, isFriendReq: true, displayUsername: self.menu_manager.friend_model.friendReqs[index].displayUsername, picture: self.menu_manager.friend_model.friendReqs[index].profilePicture)
                    
                } else {
                
                    FriendListItemView(menu_manager: self.menu_manager, isFriendReq: false, displayUsername: self.menu_manager.friend_model.friends[index].displayUsername, picture: self.menu_manager.friend_model.friends[index].profilePicture)
                }
            }
            
            Spacer()
        }
        .padding(20)
        .frame(maxWidth: .infinity)
    }
}

struct FriendListItemView: View {
    
    @ObservedObject var menu_manager: MenuViewModel
    
    @Environment(\.colorScheme) private var colorScheme
    
    var isFriendReq: Bool
    var displayUsername: String
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
                        
                }, label: {
                    Text("Accept")
                        .friendListButton(darkMode: self.colorScheme == .dark)
                })
                
                    
        // - - - - - Reject Friend Req Button - - - - - //
                Button(action: {
                        
                }, label: {
                    Text("Reject")
                        .friendListButton(darkMode: self.colorScheme == .dark)
                })
            } else {
                
                Button(action: {
                    
                }, label: {
                    Text("Unfriend")
                        .friendListButton(darkMode: self.colorScheme == .dark)
                })
            }
        }
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
