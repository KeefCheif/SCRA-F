//
//  MenuManagerModel.swift
//  SCRA-F
//
//  Created by KeefCheif on 6/21/22.
//

import Foundation
import SwiftUI

struct FriendListModel {
    
    var friends: [UserModel] = [UserModel]()
    var friendReqs: [UserModel] = [UserModel]()
    
    var friendLookup: [String: Int] = [String: Int]()       // Key: ID | Value: Index in array
    var friendReqLookup: [String: Int] = [String: Int]()
}

struct GameListModel {
    
    var games: [GameItemModel] = [GameItemModel]()
    var gameReqs: [GameReqItemModel] = [GameReqItemModel]()
}

struct UserModel: Hashable {
    
    var id: String
    var displayUsername: String
    var profilePicture: UIImage?
}

struct GameItemModel {
    
    var players: [UserModel]
    var gameType: String
    var scores: [Int]
    var turn: Int
}

struct GameReqItemModel {
    
    var players: [UserModel]
    var gameType: String
}
