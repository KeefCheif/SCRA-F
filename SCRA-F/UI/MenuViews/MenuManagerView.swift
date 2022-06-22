//
//  MenuManagerView.swift
//  SCRA-F
//
//  Created by peter allgeier on 6/21/22.
//

import SwiftUI

struct MenuManagerView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @StateObject var menu_manager: MenuViewModel
    @Binding var loggedIn: Bool
    
    @State private var tabIndex: Int = 0
    
    var body: some View {
        
        VStack {
            
            TabView(selection: self.$tabIndex) {
                Text("games")
                    .tag(0)
                    
                Text("friends")
                    .tag(1)
                    
                Text("stats")
                    .tag(2)
                    
                Text("profile")
                    .tag(3)
                    
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
    // - - - - - Bottom Nav - - - - - //
            MenuBottomNav(tabIndex: self.$tabIndex)
        }
    }
}

struct MenuManagerView_Previews: PreviewProvider {
    static var previews: some View {
        MenuManagerView(menu_manager: MenuViewModel(), loggedIn: Binding.constant(true))
    }
}
