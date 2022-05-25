//
//  AccountViewModel.swift
//  SCRA-F
//
//  Created by KeefCheif on 5/19/22.
//

import Foundation
import SwiftUI

class AccountViewModel: ObservableObject {
    
    let accountManager: AccountOperations = AccountOperations()
    
    @Published var isLoading: Bool = true
    
    @Published var error: AccountErrorType?
    @Published var model: AccountModel = AccountModel()
    @Published var profile_picture: UIImage?
    
    
    init(user: String?) {
        
        self.accountManager.signInEmail(email: "KeefCheif.dev@gmail.com", password: "testprofile") { [unowned self] (_) in
            self.accountManager.getAccountInfo(username: nil) { [unowned self] (accountModel, image, accountError) in
                
                if let accountModel = accountModel {
                    self.model = accountModel
                    self.profile_picture = image
                    self.isLoading = false
                }
            }
        }
    }
    
}
