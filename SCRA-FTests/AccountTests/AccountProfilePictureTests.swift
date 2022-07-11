//
//  AccountProfilePictureTests.swift
//  SCRA-FTests
//
//  Created by KeefCheif on 5/19/22.
//

import XCTest
import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseStorage
@testable import SCRA_F

class AccountProfilePicturesTests: XCTestCase {
    
    override func setUpWithError() throws {
        /*
        //FirebaseApp.configure()
        
        // Sign in for testing
        let signinExpectation = XCTestExpectation(description: "sign in")
        
        //AccountOperations().signInEmail(email: "SCRA.profiletest@gmail.com", password: "somePassword") { (error) in
        AccountOperations().signInEmail(email: "KeefCheif.dev@gmail.com", password: "Scubafifi1203") { (error) in
            XCTAssertNil(error)
            signinExpectation.fulfill()
        }
        
        wait(for: [signinExpectation], timeout: 10)
         */
    }
    
    func testProfilePictureOperations() throws {
        /*
        let ppManager: AccountProfilePictureManager = AccountProfilePictureManager()
        
        let uploadExpectation = XCTestExpectation(description: "upload")
        
        ppManager.uploadProfilePicture(image: UIImage(named: "Beluga")!) { (error) in
            XCTAssertNil(error)
            uploadExpectation.fulfill()
        }
        
        wait(for: [uploadExpectation], timeout: 20)
        
        let getExpectation = XCTestExpectation(description: "get")
        
        ppManager.getProfilePicture(id: Auth.auth().currentUser!.uid) { (image, error) in
            XCTAssertNotNil(image)
        }
        
        wait(for: [getExpectation], timeout: 20)
    
        let deleteExpectation = XCTestExpectation(description: "delete")
        
        do {
            try ppManager.deleteProfilePicture(completion: { (error) in
                XCTAssertNil(error)
                deleteExpectation.fulfill()
            })
        } catch {
            XCTFail()
        }
        
        wait(for: [deleteExpectation], timeout: 10)
         */
    }
}


