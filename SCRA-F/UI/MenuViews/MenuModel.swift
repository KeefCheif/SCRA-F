//
//  MenuManagerModel.swift
//  SCRA-F
//
//  Created by peter allgeier on 6/21/22.
//

import Foundation

struct MenuModel {
    
    var account_model: AccountModel = AccountModel()
    
}

enum MenuViewSelector {
    
    case games, friends, stats, profile
}
