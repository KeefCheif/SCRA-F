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
}

struct AccountFriendsModel: Codable {
    
    var friends: [AccountModel]
    var friendReqs: [AccountModel]
}

struct AccountGamesModel: Codable {
    
    var games: [AccountGameModel]
    var gameReqs: [AccountGameReqModel]
}

struct AccountGameModel: Codable {
    
    var players: [AccountModel]
    var scores: [Int]
    var turn: Int
    var gameType: String
}

struct AccountGameReqModel: Codable {
    
    var players: [AccountModel]
    var gameType: String
}

