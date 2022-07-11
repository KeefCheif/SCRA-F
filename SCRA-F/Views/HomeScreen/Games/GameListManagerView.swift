//
//  GameListManagerView.swift
//  SCRA-F
//
//  Created by KeefCheif on 6/22/22.
//

import SwiftUI

struct GameListManagerView: View {
    
    @ObservedObject var menu_manager: MenuViewModel
    
    var body: some View {
        
        VStack {

        }
    }
}

struct GameListManagerView_Previews: PreviewProvider {
    static var previews: some View {
        GameListManagerView(menu_manager: MenuViewModel())
    }
}
