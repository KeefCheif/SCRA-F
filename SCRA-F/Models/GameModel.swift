//
//  GameModel.swift
//  SCRA-F
//
//  Created by peter allgeier on 6/8/22.
//

import Foundation

struct GameModel: Codable {
    var settings: GameSettings
    var state: GameState
    var players: GamePlayer
}

struct GameSettings: Codable {
    
    var startDate: String
    
    var boardType: String
    var letterType: String
    
    var timeRestriction: Bool
    var timeLimit: Int?
    
    var inactivityTimer: Bool
    var inactivityTimeLimit: Int?
    
    var challenges: Bool
    var freeChallenges: Int?
    
    var playerCount: Int
    
    var players: [String]
    var playerIDs: [String]
}

struct GameState: Codable {
    
    var lock: Bool
    var gameStarted: Bool
    
    var board: [String]
    var letters: [String]
    
    var turn: Int
    var turnStarted: Bool
    
    var scores: [Int]
}

struct GamePlayer: Codable {
    var letters: [String]
    var alert: [String]
    var lostTurn: Bool
}

/*
 Consider moving each player's data to its own section in the DB
 */
