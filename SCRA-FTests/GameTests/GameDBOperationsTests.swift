//
//  GameDBOperationsTests.swift
//  SCRA-FTests
//
//  Created by KeefCheif on 5/24/22.
//

import XCTest
import Firebase
import FirebaseAuth
@testable import SCRA_F

class GameOperationsTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Nothing
    }
    
    func testAccountOperations() throws {
        
        let accountManager: AccountOperations = AccountOperations()
        let gameOperationManager: GameOperations = GameOperations()
        
        // Sign in
        let signinExpectation = XCTestExpectation(description: "Sign in")
        
        accountManager.signInEmail(email: "SCRA.gameTest@gmail.com", password: "somePassword") { error in
            XCTAssertNil(error)
            signinExpectation.fulfill()
        }
        
        wait(for: [signinExpectation], timeout: 10)
        
        // Create new game
        let settings: [String: Any] = [
            "boardType": "default",
            "lettersType": "default",
            "timeRestriction": true,
            "timeLimit": 300,
            "challenges": true,
            "freeChallenges": 1,
            "playerCount": 3,
            "player1": "gameTest",
            "player1Id": Auth.auth().currentUser!.uid,
            "player2": "gameTest2",
            "player2Id": "jCin4wabjuT9suzd8ZKb7c3uBgf2",
            "player3": "gameTest3",
            "player3Id": "1QPrhdwlWehEg1iqcLvb8KnbEu12"
        ]
        
        let newGameExpectation = XCTestExpectation(description: "new game")
        
        let gameId: String = gameOperationManager.newGame(creatorId: Auth.auth().currentUser!.uid, players: [(Auth.auth().currentUser!.uid, "gameTest"), ("jCin4wabjuT9suzd8ZKb7c3uBgf2", "gameTest2"), ("1QPrhdwlWehEg1iqcLvb8KnbEu12", "gameTest3")], settings: settings) { error in
            XCTAssertNil(error)
            newGameExpectation.fulfill()
        }
        
        wait(for: [newGameExpectation], timeout: 15)
        
        // Add player to the game
        let addPlayer2Expectation = XCTestExpectation(description: "add player 2")
        let addPlayer3Expectation = XCTestExpectation(description: "add player 3")
        
        gameOperationManager.addPlayer(id: "jCin4wabjuT9suzd8ZKb7c3uBgf2", gameId: gameId) { error in
            XCTAssertNil(error)
            addPlayer2Expectation.fulfill()
        }
        
        gameOperationManager.addPlayer(id: "1QPrhdwlWehEg1iqcLvb8KnbEu12", gameId: gameId) { error in
            XCTAssertNil(error)
            addPlayer3Expectation.fulfill()
        }
        
        wait(for: [addPlayer2Expectation, addPlayer3Expectation], timeout: 10)
        
        // Check waitlist
        //let getGameExpectation = XCTestExpectation(description: "get game")
        
        // Delete Game
        let deleteGameExpectation = XCTestExpectation(description: "delete game")
        
        gameOperationManager.deleteGame(gameId: gameId) { error in
            XCTAssertNil(error)
            deleteGameExpectation.fulfill()
        }
        
        wait(for: [deleteGameExpectation], timeout: 10)
    }
}
