//
//  MenuBottomNav.swift
//  SCRA-F
//
//  Created by KeefCheif on 6/22/22.
//

import SwiftUI

struct MenuBottomNav: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @Binding var tabIndex: Int
    
    let profile_picture: UIImage?
    
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
                if let profile_picture = profile_picture {
                    Image(uiImage: profile_picture)
                        .profileTabBarItem()
                } else {
                    Image(systemName: "person.circle")
                        .tabBarItem(darkMode: self.colorScheme == .dark, selection: self.tabIndex, tag: 2)
                }
            })
            
            Spacer()
        }
        .padding(10)
        .background(self.colorScheme == .dark ? .white : .black)
    }
}

struct MenuBottomNav_Previews: PreviewProvider {
    static var previews: some View {
        MenuBottomNav(tabIndex: Binding.constant(0), profile_picture: nil)
    }
}

extension Image {
    func tabBarItem(darkMode: Bool, selection: Int, tag: Int) -> some View {
        
        if selection == tag {
            return self.resizable().scaledToFit().frame(maxWidth: 40).foregroundColor(Color(uiColor: .systemBlue)).padding([.top], 5)
        } else {
            return self.resizable().scaledToFit().frame(maxWidth: 40).foregroundColor(darkMode ? .black : .white).padding([.top], 5)
        }
    }
    
    func profileTabBarItem() -> some View {
        self.resizable().scaledToFill().frame(width: 40, height: 40).clipShape(Circle())
    }
}
