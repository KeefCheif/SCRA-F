//
//  AccountViewModel.swift
//  SCRA-F
//
//  Created by KeefCheif on 5/19/22.
//

import Foundation
import SwiftUI
import FirebaseAuth

class AccountViewModel: ObservableObject {
    
    let accountManager: AccountOperations = AccountOperations()
    
    @Published var isLoading: Bool = true
    
    @Published var error: AccountErrorType?
    @Published var model: AccountModel = AccountModel()
    @Published var profile_picture: UIImage?
    
    
    init(user: String?) {
        
        self.accountManager.getAccountInfo(username: nil) { (m, image, error) in
            if let error = error {
                print(error.localizedDescription)
            } else if let m = m {
                self.model = m
                self.profile_picture = image
                self.isLoading = false
            }
        }
    }
    
}
