//
//  AccountView.swift
//  SCRA-F
//
//  Created by peter allgeier on 5/19/22.
//

import SwiftUI

struct AccountView: View {
    
    @StateObject var view_model: AccountViewModel
    
    var body: some View {
        
        if self.view_model.isLoading {
            Text("Loading")
        } else {
            VStack {
                if self.view_model.model.hasProfilePicture {
                    Image(uiImage: self.view_model.model.profilePicture!)
                }
            }
        }
    }
}

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        AccountView(view_model: AccountViewModel(user: nil))
    }
}
