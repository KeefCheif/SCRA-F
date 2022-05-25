//
//  AccountDBOperationsTests.swift
//  SCRA-FTests
//
//  Created by KeefCheif on 5/18/22.
//

import XCTest
import Firebase
import FirebaseAuth
@testable import SCRA_F

class AccountDBOperationsTests: XCTestCase {
    
    override func setUpWithError() throws {
        //FirebaseApp.configure()
    }
    
    func testAccountOperations() throws {
        
        let account: AccountOperations = AccountOperations()
        
        let createExpectation = XCTestExpectation(description: "create")
        
        account.createAccount(username: "TestUser", email: "SCRA.test@gmail.com", password: "somePassword") { (error) in
            XCTAssertNil(error)
            createExpectation.fulfill()
        }
        
        wait(for: [createExpectation], timeout: 10)
        
        let loginExpectation = XCTestExpectation(description: "Login")
        
        account.signInEmail(email: "SCRA.test@gmail.com", password: "somePassword") { error in
            XCTAssertNil(error)
            XCTAssertNotNil(Auth.auth().currentUser)
            loginExpectation.fulfill()
        }
        
        wait(for: [loginExpectation], timeout: 10)
        XCTAssertNotNil(Auth.auth().currentUser)
        
        let getAccountExpectation = XCTestExpectation(description: "get account")
        
        account.getAccountInfo(username: nil) { (model, image, error) in
            XCTAssertNil(error)
            XCTAssertNotNil(model)
            XCTAssertNotNil(model!.username)
            XCTAssertNotNil(model!.displayUsername)
            XCTAssertEqual(model!.displayUsername, "TestUser")
            XCTAssertFalse(model!.hasProfilePicture)
            XCTAssertNotNil(model!.games)
            XCTAssertEqual(model!.games, [])
            getAccountExpectation.fulfill()
        }
        
        wait(for: [getAccountExpectation], timeout: 10)
        
        let deleteExpectation = XCTestExpectation(description: "delete")
        
        account.deleteAccount(username: "TestUser") { error in
            XCTAssertNil(error)
            deleteExpectation.fulfill()
        }
        
        wait(for: [deleteExpectation], timeout: 10)
        
        let userLookupExpectation = XCTestExpectation(description: "user lookup")
        
        account.getAccountInfo(username: "TestUser") { (model, image, error) in
            XCTAssertNotNil(error)
            userLookupExpectation.fulfill()
        }
        
        wait(for: [userLookupExpectation], timeout: 10)
    }
}

