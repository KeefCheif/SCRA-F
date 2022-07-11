//
//  MenuManagerView.swift
//  SCRA-F
//
//  Created by KeefCheif on 6/21/22.
//

import SwiftUI

struct MenuManagerView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @StateObject var menu_manager: MenuViewModel
    @Binding var loggedIn: Bool
    
    @State private var tabIndex: Int = 0
    
    var body: some View {
        
        if self.menu_manager.isLoading {
            GenericLoadingView()
        } else {
         
            VStack {
                
                Button(action: {
                    self.menu_manager.logout(loggedIn: &self.loggedIn)
                }, label: {
                    Text("Logout")
                })
                
                TabView(selection: self.$tabIndex) {
                    Text("games")
                        .tag(0)
                        
                    FriendListManagerView(menu_manager: self.menu_manager)
                        .tag(1)
                        
                    ProfileView(menu_manager: self.menu_manager)
                        .tag(2)
                        
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
        // - - - - - Bottom Nav - - - - - //
                MenuBottomNav(tabIndex: self.$tabIndex, profile_picture: self.menu_manager.profile_picture)
            }
            
        }
    }
}

struct MenuManagerView_Previews: PreviewProvider {
    static var previews: some View {
        MenuManagerView(menu_manager: MenuViewModel(), loggedIn: Binding.constant(true))
    }
}
