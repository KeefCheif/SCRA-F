//
//  MenuManagerViewModel.swift
//  SCRA-F
//
//  Created by KeefCheif on 6/21/22.
//

import Foundation
import SwiftUI

class MenuViewModel: ObservableObject {
    
    @Published var isLoading: Bool = true
    
    @Published var menu_model: MenuModel = MenuModel()
    @Published var profile_picture: UIImage?
    
    @Published var menu_view_manager: MenuViewSelector = MenuViewSelector.games
    
    @Published var account_error: AccountErrorType?
    
    private let accountManager: AccountOperations = AccountOperations()
    
    init() {
        
        self.accountManager.getAccountInfo(username: nil) { [unowned self] (profile, picture, error) in
            
            if let error = error {
                self.account_error = AccountErrorType(error: error)
            } else if let profile = profile {
                self.menu_model.account_model = profile
                self.profile_picture = picture
            } else {
                self.account_error = AccountErrorType(error: .uniqueError("Failed to get account info."))
            }
            
            self.isLoading = false
        }
    }
    
}
