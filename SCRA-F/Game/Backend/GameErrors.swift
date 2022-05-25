//
//  GameErrors.swift
//  SCRA-F
//
//  Created by peter allgeier on 5/23/22.
//

import Foundation

enum GameError: Error, LocalizedError {
    
    case createGame
    case deleteGame
    
    case getGame
    
    case addPlayer
    case removePlayer
    
    var errorDescription: String? {
        
        switch self {
        case .createGame:
            return NSLocalizedString("Failed to create the game.", comment: "")
        case .deleteGame:
            return NSLocalizedString("Failed to delete the game.", comment: "")
            
        case .getGame:
            return NSLocalizedString("Failed to get game data.", comment: "")
            
        case .addPlayer:
            return NSLocalizedString("Failed to add player to the game.", comment: "")
        case .removePlayer:
            return NSLocalizedString("Failed to remove player from the game.", comment: "")
        }
    }
}

struct GameErrorType: Identifiable {
    let id = UUID()
    let error: GameError
}
