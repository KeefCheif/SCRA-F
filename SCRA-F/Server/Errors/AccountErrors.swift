//
//  AccountErrors.swift
//  SCRA-F
//
//  Created by KeefCheif on 5/18/22.
//

import Foundation

enum AccountError: Error, LocalizedError {
    
    case usernameTaken(String)
    case usernameInvalid
    case usernameTooLong
    case usernameTooShort
    
    case loginFailedUsername(String)
    
    case selfFriendReq
    case alreadyFriends
    case failedAcceptFriendReq(String)
    
    case failedSendGameReq(String)
    
    case imageTooLarge
    
    case notLoggedIn
    case propogatedError(String)
    case uniqueError(String)
    case userNotFound(String)
    
    var errorDescription: String? {
        
        switch self {
        case .usernameTaken(let username):
            return NSLocalizedString("The username '\(username)' is already taken. Please enter a different username.", comment: "")
        case .usernameInvalid:
            return NSLocalizedString("This username is incorrectly formatted. Only numbers, letters, and underscores are allowed.", comment: "")
        case .usernameTooLong:
            return NSLocalizedString("Your username is too long. The limit is 20 characters.", comment: "")
        case .usernameTooShort:
            return NSLocalizedString("Your username is too short. It must be at least 2 characters", comment: "")
            
        case .loginFailedUsername(let username):
            return NSLocalizedString("There is no user with the username '\(username)'.", comment: "")
            
        case .selfFriendReq:
            return NSLocalizedString("You cannot send a friend request to yourself.", comment: "")
        case .alreadyFriends:
            return NSLocalizedString("You cannot send a friend request to this user because you are already friends.", comment: "")
        case .failedAcceptFriendReq(let username):
            return NSLocalizedString("Failed to accept the friend request from '\(username)'.", comment: "")
            
        case .failedSendGameReq(let username):
            return NSLocalizedString("Failed to send the game request to '\(username)'.", comment: "")
            
        case .imageTooLarge:
            return NSLocalizedString("The file is too large to upload even after maximum compression.", comment: "")
        
        case .notLoggedIn:
            return NSLocalizedString("You are no longer signed in.", comment: "")
        case .propogatedError(let message):
            return NSLocalizedString(message, comment: "")
        case .uniqueError(let message):
            return NSLocalizedString(message, comment: "")
        case .userNotFound(let username):
            return NSLocalizedString("A user with the username '\(username)' could not be found.", comment: "")
        }
    }
}

struct AccountErrorType: Identifiable {
    let id = UUID()
    let error: AccountError
}
