//
//  SCRA_FApp.swift
//  SCRA-F
//
//  Created by KeefCheif on 5/18/22.
//

import SwiftUI
import Firebase
import FirebaseAuth

@main
struct SCRA_FApp: App {
    
    init() {
        FirebaseApp.configure()
        
        //try! Auth.auth().signOut()
    }
    
    var body: some Scene {
        WindowGroup {
            LoginManagerView(login_manager: LoginManagerViewModel())
        }
    }
}
