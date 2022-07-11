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
    
    public func newGame(creatorId: String, players: [(String, String)], settings: [String: Any], completion: @escaping (GameError?) -> Void) -> String {
        
        let game = self.db.collection("games").addDocument(data: self.prepGameData(creatorId: creatorId, players: players, settings: settings)) { error in
            if let _ = error {
                completion(GameError.createGame)
            } else {
                completion(nil)
            }
        }
        
        return game.documentID
    }
    
    
    private func prepGameData(creatorId: String, players: [(String, String)], settings: [String: Any]) -> [String: Any] {
        
        // First, get the board and letter bag depending on the game settings
        var board: [String] = [String]()
        var letters: [String] = [String]()
        
        switch settings["boardType"]! as! String {
        case "boostless":
            board = GameInfo.BOOSTLESS_BOARD
        default:
            board = GameInfo.DEFAULT_BOARD
        }
        
        switch settings["letterType"]! as! String {
        default:
            letters = GameInfo.DEFAULT_LETTER_BAG
        }
        
        // Second, prep each component of the game: settings, state, waitlist, & player info
        var gameSettings: [String: Any] = settings
        
        var gameState: [String: Any] = [
            "lock": false,
            "gameStarted": false,
            "board": board,
            "letters": letters,
            "turn": 1,
            "turnStarted": false
        ]
        
        var gameData: [String: Any] = [
            "waitList": [String]()
        ]
        
        for (index, player) in players.enumerated() {
            
            let player_number: String = String(index)
            
            if player.0 != creatorId {
                gameData["waitList"] = gameData["waitList"]! as! [String] + [player.0]
            }
            
            gameData[creatorId] = [
                "letters": [String](),
                "alert": [String](),
                "lostTurn": false
            ]
            
            gameState["p" + player_number + "Score"] = 0
            gameSettings["player" + player_number + "ID"] = player.0
            gameSettings["player" + player_number] = player.1
        }
        
        gameData["gameState"] = gameState
        gameData["gameSettings"] = gameSettings
        
        return gameData
    }
    
    // - - - - - - - - - - G E T   G A M E   D A T A - - - - - - - - - - //
    
    func getGameModel(gameId: String, id: String, completion: @escaping (GameModel?, GameError?, [String]?) -> Void) {
        
        // Use the private method: getGameData to retrieve the entire game document
        // ~ Note: Might change this by moving the player data out of the game doc and into its own location within each respective user's doc
        //         This would prevent the app from loading in the game data for every player which it currently does (stored in gameData)
        
        self.getGameInfo(gameId: gameId) { (gameData, error) in
            if let error = error {
                completion(nil, error, nil)
            } else if let gameData = gameData {
                
                // Get each component from the gameData
                let waitList: [String]? = gameData["waitList"] as? [String]
                let settings: [String: Any]? = gameData["gameSettings"] as? [String: Any]
                let state: [String: Any]? = gameData["gameState"] as? [String: Any]
                let player: [String: Any]? = gameData[id] as? [String: Any]
                
                do {
                    
                    let decoder = JSONDecoder()
                    
                    if let settings = settings, let state = state, let player = player {
                        
                // Convert each component from the game data into its respective model form
                        let jsonSettings = try JSONSerialization.data(withJSONObject: settings)
                        let decodedSettings = try decoder.decode(GameSettings.self, from: jsonSettings)
                        
                        let jsonState = try JSONSerialization.data(withJSONObject: state)
                        let decodedState = try decoder.decode(GameState.self, from: jsonState)
                        
                        let jsonPlayer = try JSONSerialization.data(withJSONObject: player)
                        let decodedPlayer = try decoder.decode(GamePlayer.self, from: jsonPlayer)
                        
                // Determine if there is a waitlist and complete accordingly: The game cannot start if there is a waitlist
                        if let waitList = waitList {
                            completion(GameModel(settings: decodedSettings, state: decodedState, players: decodedPlayer), nil, waitList)
                        } else {
                            completion(GameModel(settings: decodedSettings, state: decodedState, players: decodedPlayer), nil, nil)
                        }
                        
                    } else {
                        throw GameError.getGameModel
                    }
                    
                } catch {
                    completion(nil, GameError.getGameModel, nil)
                }
                
            } else {
                completion(nil, GameError.getGame, nil)
            }
        }
    }
    
    private func getGameInfo(gameId: String, completion: @escaping ([String: Any]?, GameError?) -> Void) {
        
        let gameDoc = self.db.collection("games").document(gameId)
        
        gameDoc.getDocument { (docSnap, error) in
            if let _ = error {
                completion(nil, GameError.getGame)
            } else if let docSnap = docSnap {
                completion(docSnap.data(), nil)
            } else {
                completion(nil, GameError.getGame)
            }
        }
    }
    
    // - - - - - - - - - - R E S P O N D   G A M E   I N V I T E - - - - - - - - - - //
    
    func acceptGameInvite(id: String, gameId: String, completion: @escaping (GameError?) -> Void) {
        
        let gameDoc = self.db.collection("games").document(gameId)
        
        // Get the entire game document so it can be modified
        self.getGameInfo(gameId: gameId) { (gameData, error) in
            if let error = error {
                completion(error)
            } else if let gameData = gameData {
                
                var state: [String: Any] = gameData["gameState"]! as! [String: Any]
                var waitList: [String] = gameData["waitList"]! as! [String]
                
                if waitList.contains(id) {
                    waitList.remove(at: waitList.firstIndex(of: id)!)
                }
                
                if waitList.isEmpty {
                    
                    state["gameStarted"] = true
                    
                    gameDoc.updateData([
                        "waitList": FieldValue.delete(),
                        "gameState": state
                    ])
                    
                } else {
                    gameDoc.updateData([
                        "waitList": waitList,
                    ])
                }
                
                completion(nil)
                
            } else {
                completion(GameError.getGame)
            }
        }
    }
    
    
    func rejectGameInvite(id: String, gameId: String, completion: @escaping (GameError?) -> Void) {
        
        let gameDoc = self.db.collection("games").document(gameId)
        
        self.getGameInfo(gameId: gameId) { (gameData, error) in
            if let error = error {
                completion(error)
            } else if let gameData = gameData {
                
                var settings: [String: Any] = gameData["gameSettings"]! as! [String: Any]
                var state: [String: Any] = gameData["gameSettings"]! as! [String: Any]
                
                let player_count: Int = settings["playerCount"]! as! Int
                var player_number: Int = 1
                
            // Determine which player is rejecting the invite. For example, player2
                while player_number <= player_count {
                    if settings["player" + String(player_number) + "ID"]! as! String == id {
                        break
                    }
                    player_number += 1
                }
                
            // Push each player above the player who quit down
            // For example, if player2 quit then player2 would be overwritten with player3 & player3 would be overwritten with player4
                for i in player_number..<player_count {
                    
                    let currentKey: String = String(i)
                    let nextKey:String = String(i + 1)
                    
                    settings["player" + currentKey + "ID"] = settings["player" + nextKey + "ID"]! as! String
                    settings["player" + currentKey] = settings["player" + nextKey]! as! String
                    state["p" + currentKey + "Score"] = state["p" + nextKey + "Score"]! as! Int
                }
                
            // Delete the leftover player
                settings["player" + String(player_count) + "ID"] = nil
                settings["player" + String(player_count)] = nil
                state["p" + String(player_count) + "Score"] = nil
                
            // Update the waitlist
                let waitList: [String] = gameData["waitList"]! as! [String]
                let new_waitList: [String] = waitList.filter { $0 != id }
                
            // Save the changes to the DB
                gameDoc.updateData([
                    "waitList": new_waitList.isEmpty ? FieldValue.delete() : new_waitList,
                    "gameSettings": settings,
                    "gameState": state,
                    "id": FieldValue.delete()
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
    
    // - - - - - - - - - - E N D  G A M E - - - - - - - - - - //
    
    
    
}

/*
struct GameOperations {
    
    let db = Firestore.firestore()
    
    // - - - - - - - - - - D E L E T E   G A M E - - - - - - - - - - //
    
    // ~ Note the delete function does not care if each user still has a reference to the game
    public func deleteGame(gameId: String, completion: @escaping (GameError?) -> Void) {
        
        let _ = self.db.collection("games").document(gameId).delete() { error in
            if let _ = error {
                completion(GameError.deleteGame)
            } else {
                completion(nil)
            }
        }
    }
    
    // - - - - - - - - - - G E T   G A M E   I N F O - - - - - - - - - - //
    
    public func getPlayerGameData(id: String, gameId: String, completion: @escaping () -> Void) {
        
        
        
    }
    
    private func getGameInfo(gameId: String, completion: @escaping ([String: Any]?, GameError?) -> Void) {
        
        let gameDoc = self.db.collection("games").document(gameId)
        
        gameDoc.getDocument { (docSnap, error) in
            if let _ = error {
                completion(nil, GameError.getGame)
            } else if let docSnap = docSnap {
                completion(docSnap.data(), nil)
            } else {
                completion(nil, GameError.getGame)
            }
        }
        
    }
    
    // - - - - - - - - - - A D D   P L A Y E R - - - - - - - - - //
    
    func addPlayer(id: String, gameId: String, completion: @escaping (GameError?) -> Void) {
        
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
                    
                    let player: String = "player" + String(crawler) + "Id"
                    
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
                    settings["player" + String(crawler) + "Id"] = settings["player" + String(crawler + 1) + "Id"]!
                    settings["player" + String(crawler)] = settings["player" + String(crawler + 1)]!
                    state["p" + String(crawler) + "Score"] = state["p" + String(crawler + 1) + "Score"]!
                    crawler += 1
                }
                
                // Remove the last player from the db since there is now 1 fewer players
                settings["player" + String(crawler) + "Id"] = nil
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
*/
