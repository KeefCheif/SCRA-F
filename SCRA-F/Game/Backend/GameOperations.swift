//
//  GameOperations.swift
//  SCRA-F
//
//  Created by KeefCheif on 5/23/22.
//

import Firebase
import FirebaseAuth

struct GameOperations {
    
    let db = Firestore.firestore()
    
    // - - - - - - - - - - C R E A T E   G A M E - - - - - - - - - - //
    
    public func newGame(creatorId: String, players: [(String, String)], settings: [String: Any]) -> String {
        
        let gameData = self.prepGameData(creatorId: creatorId, players: players, settings: settings)
        
        let game = self.db.collection("games").addDocument(data: gameData)
        
        return game.documentID
    }
    
    private func prepGameData(creatorId: String, players: [(String, String)], settings: [String: Any]) -> [String: Any] {
        
        // Get the board type from the settings
        var board: [String] = [String]()
        
        let boardType: String = settings["boardType"]! as! String
        switch boardType {
        case "boostless":
            board = GameInfo.BOOSTLESS_BOARD
        default:
            board = GameInfo.DEFAULT_BOARD
        }
        
        // Get the letters type from the settings
        var letters: [String] = [String]()
        
        let lettersType: String = settings["lettersType"]! as! String
        switch lettersType {
        default:
            letters = GameInfo.DEFAULT_LETTER_BAG
        }
        
        var gameState: [String: Any] = [
            "board": board,
            "letters": letters,
            "turn": 1,
            "turnStarted": false
        ]
        
        // Prepare the gameSettings
        var gameSettings: [String: Any] = settings
        gameSettings["lettersType"] = nil
        gameSettings["boardType"] = nil
        
        var gameData: [String: Any] = [
            "gameSettings": gameSettings,
            "waitingFor": [String]()
        ]
        
        // Add the players to the game info
        for (number, player) in players.enumerated() {
            
            let playerNum: String = "p" + String(number) + "Score"
            
            if player.0 != creatorId {
                gameData["waitingFor"] = [gameData["waitingFor"]! as! [String] + [player.0]]
            }
            
            gameData[player.0] = [
                "playerNumber": number,
                "letter": [String](),
                "lostTurn": false
            ]
            
            gameState[playerNum] = 0
        }
        
        // Add the game state to the game data
        gameData["gameState"] = gameState
        
        return gameData
    }
    
    // - - - - - - - - - - G E T   G A M E   I N F O - - - - - - - - - - //
    
    public func getPlayerData(id: String, gameId: String, completion: @escaping () -> Void) {
        
        
        
    }
    
    private func getGameInfo(gameId: String, completion: @escaping ([String: Any]?, GameError?) -> Void) {
        
        let gameDoc = self.db.collection("games").document(gameId)
        
        gameDoc.getDocument { (docSnap, error) in
            if let _ = error {
                completion(nil, GameError.getGame)
            } else if let docSnap = docSnap {
                
                let data = docSnap.data()!
                
                completion(data, nil)
                
            } else {
                completion(nil, GameError.getGame)
            }
        }
        
    }
    
    // - - - - - - - - - - A D D   P L A Y E R - - - - - - - - - //
    
    func addPlayer(username: String, id: String, gameId: String, completion: @escaping (GameError?) -> Void) {
        
        let gameDoc = self.db.collection("games").document(gameId)
        
        gameDoc.updateData([
            "waitingFor": FieldValue.arrayRemove([id]),
        ]) { error in
            if let _ = error {
                completion(GameError.addPlayer)
            } else {
                completion(nil)
            }
        }
    }
    
    // - - - - - - - - - - R E M O V E   P L A Y E R - - - - - - - - - - //
    
    func removePlayer(id: String, gameId: String, completion: @escaping (GameError?) -> Void) {
        
        let gameDoc = self.db.collection("games").document(gameId)
        
        // Get the current game data from the Firestore DB
        self.getGameInfo(gameId: gameId) { (gameData, error) in
            if let gameData = gameData {
                
                // Data in the settings and the state needs to be modified if someone quits the game
                var settings: [String: Any] = gameData["gameSettings"]! as! [String: Any]
                var state: [String: Any] = gameData["gameState"]! as! [String: Any]
                
                let turn: Int = state["turn"]! as! Int
                let player_count: Int = settings["playerCount"]! as! Int
                
                // Figure out which player the user that quit was... for example player2
                var crawler: Int = 1
                while crawler <= player_count {
                    
                    let player: String = "player" + String(crawler) + "ID"
                    
                    if settings[player] != nil && settings[player]! as! String == id {
                        break
                    }
                    
                    crawler += 1
                }
                
                // Update the turn if it was not the person who quit's turn
                if turn != crawler {
                    state["turn"] = turn > crawler ? turn - 1 : turn
                }
                
                // Remove the player # that the user was and bump every other player above them down by one
                // Example: player2 quit, so player3 becomes player2 & player4 becoms player3 and so on
                while crawler <= player_count - 1 {
                    settings["player" + String(crawler) + "ID"] = settings["player" + String(crawler + 1) + "ID"]!
                    settings["player" + String(crawler)] = settings["player" + String(crawler + 1)]!
                    state["p" + String(crawler) + "Score"] = state["p" + String(crawler + 1) + "Score"]!
                }
                
                // Remove the last player from the db since there is now 1 fewer players
                settings["player" + String(crawler) + "ID"] = nil
                settings["player" + String(crawler)] = nil
                settings["playerCount"] = player_count - 1
                state["p" + String(crawler) + "Score"] = nil
                
                // Update the data in the DB
                gameDoc.updateData([
                    id: FieldValue.delete(),
                    "gameSettings": settings,
                    "gameState": state
                ]) { updateError in
                    if let _ = updateError {
                        completion(GameError.removePlayer)
                    } else {
                        completion(nil)
                    }
                }
                
            } else {
                completion(GameError.getGame)
            }
        }
    }
}
