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
        FirebaseApp.configure()
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
        
        account.getAccountInfo { (model, error) in
            XCTAssertNil(error)
            XCTAssertNotNil(model)
            XCTAssertNotNil(model!.username)
            XCTAssertNotNil(model!.displayUsername)
            XCTAssertEqual(model!.displayUsername, "TestUser")
            getAccountExpectation.fulfill()
        }
        
        wait(for: [getAccountExpectation], timeout: 10)
        
        let deleteExpectation = XCTestExpectation(description: "delete")
        
        do {
            try account.deleteAccount { error in
                XCTAssertNil(error)
                deleteExpectation.fulfill()
            }
        } catch {
            XCTFail(error.localizedDescription)
        }
        
        wait(for: [deleteExpectation], timeout: 10)
    }
}

