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
            "letterType": "default",
            "timeRestriction": true,
            "timeLimit": 300,
            "inactivityTimer": true,
            "inactivityTimeLimit": 3600,
            "challenges": true,
            "freeChallenges": 1,
            "playerCount": 4
        ]
        
        let newGameExpectation = XCTestExpectation(description: "new game")
        
        let gameId: String = gameOperationManager.newGame(creatorId: Auth.auth().currentUser!.uid, players: [(Auth.auth().currentUser!.uid, "gameTest"), ("jCin4wabjuT9suzd8ZKb7c3uBgf2", "gameTest2"), ("1QPrhdwlWehEg1iqcLvb8KnbEu12", "gameTest3")], settings: settings) { error in
            XCTAssertNil(error)
            newGameExpectation.fulfill()
        }
        
        wait(for: [newGameExpectation], timeout: 10)
        
        //
    }
}
