//
//  AccountModel.swift
//  SCRA-F
//
//  Created by KeefCheif on 5/19/22.
//

import Foundation

struct AccountModel: Codable {
    
    var id: String = ""
    var displayUsername: String = ""
    var username: String = ""
    
    var hasProfilePicture: Bool = false
    
    var games: [GameListItem]?
    var gameReq: [GameRequestListItem]?
    
    var friends: [FriendModel]?
    var friendReq: [FriendModel]?
    var pendingFriendReq: [FriendModel]?
}

struct FriendModel: Codable, Hashable {
    
    var displayUsername: String
    var id: String
}

struct GameRequestListItem: Codable, Hashable {
    
    var players: [FriendModel] = [FriendModel]()
    var gameType: String = ""
}

struct GameListItem: Codable {
    
    var players: [FriendModel] = [FriendModel]()

    var scores: [Int] = [Int]()
    var turn: Int = 1
}
