//
//  AccountModel.swift
//  SCRA-F
//
//  Created by KeefCheif on 5/19/22.
//

import Foundation

struct AccountModel: Codable {
    var displayUsername: String = ""
    var username: String = ""
    
    var hasProfilePicture: Bool = false
    
    var games: [String]?
    var gameReq: [gameRequest]?
    
    var friends: [String]?
    var friendReq: [String]?
    var pendingFriendReq: [String]?
}

struct gameRequest: Codable {
    var from: String = ""
    var gameId: String = ""
}
