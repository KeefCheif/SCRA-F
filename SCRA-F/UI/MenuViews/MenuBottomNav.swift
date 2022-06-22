//
//  MenuBottomNav.swift
//  SCRA-F
//
//  Created by peter allgeier on 6/22/22.
//

import SwiftUI

struct MenuBottomNav: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @Binding var tabIndex: Int
    
    var body: some View {
        
        HStack {
            Spacer()
            
            Button(action: {
                self.tabIndex = 0
            }, label: {
                Image(systemName: "list.bullet")
                    .tabBarItem(darkMode: self.colorScheme == .dark, selection: self.tabIndex, tag: 0)
            })
            
            Spacer()
            
            Button(action: {
                self.tabIndex = 1
            }, label: {
                Image(systemName: "person.2")
                    .tabBarItem(darkMode: self.colorScheme == .dark, selection: self.tabIndex, tag: 1)
            })
            
            Spacer()
            
            Button(action: {
                self.tabIndex = 2
            }, label: {
                Image(systemName: "square.and.pencil")
                    .tabBarItem(darkMode: self.colorScheme == .dark, selection: self.tabIndex, tag: 2)
            })
            
            Spacer()
            
            Button(action: {
                self.tabIndex = 3
            }, label: {
                Image(systemName: "person.circle")
                    .tabBarItem(darkMode: self.colorScheme == .dark, selection: self.tabIndex, tag: 3)
            })
            
            Spacer()
        }
        .padding(10)
        .background(self.colorScheme == .dark ? .white : .black)
    }
}

struct MenuBottomNav_Previews: PreviewProvider {
    static var previews: some View {
        MenuBottomNav(tabIndex: Binding.constant(0))
    }
}

extension Image {
    func tabBarItem(darkMode: Bool, selection: Int, tag: Int) -> some View {
        
        if selection == tag {
            return self.resizable().scaledToFit().frame(maxWidth: 30).foregroundColor(Color(uiColor: .systemBlue)).padding([.top], 5)
        } else {
            return self.resizable().scaledToFit().frame(maxWidth: 30).foregroundColor(darkMode ? .black : .white).padding([.top], 5)
        }
    }
}
