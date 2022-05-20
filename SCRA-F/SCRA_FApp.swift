//
//  SCRA_FApp.swift
//  SCRA-F
//
//  Created by peter allgeier on 5/18/22.
//

import SwiftUI
import Firebase

@main
struct SCRA_FApp: App {
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            AccountView(view_model: AccountViewModel(user: nil))
        }
    }
}
