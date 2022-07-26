//
//  AccountDatabaseOperations.swift
//  SCRA-F
//
//  Created by KeefCheif on 5/18/22.
//

import Firebase
import FirebaseAuth
import SwiftUI

struct AccountOperations {
    
    private let db = Firestore.firestore()
    
    // - - - - - - - - - - R E G I S T E R - - - - - - - - - - //
    
    public func createAccount(username: String, email: String, password: String, completion: @escaping (AccountError?) -> Void) {
        
        let lowercased_username: String = username.lowercased()
        
        Auth.auth().createUser(withEmail: email, password: password) { (_, error) in
            DispatchQueue.main.async {
                if let error = error {
                    completion(AccountError.propogatedError(error.localizedDescription))
                } else {
                    
                    let userId: String = Auth.auth().currentUser!.uid
                    
                    // Add the new user's info to the general user lookup section in the DB so that they can easily be found and enforce that there are no duplicate usernames made
                    let userLookup = self.db.collection("users").document("usernames")
                    let userDoc = db.collection("users").document(userId)
                    
                    userLookup.setData([
                        "displayLookup": [lowercased_username: username],
                        "userLookup": [lowercased_username: userId],
                        "usernames": FieldValue.arrayUnion([lowercased_username])
                    ], merge: true) { (userLookupError) in
                        
                        if let _ = userLookupError {
                            completion(AccountError.uniqueError("Failed to set user lookup info."))
                        } else {
                            
                            let social_collection = userDoc.collection("social")
                            
                            social_collection.document("friends").setData([
                                "friends": [],
                                "friendReqs": []
                            ])
                            
                            social_collection.document("games").setData([
                                "games": [],
                                "gameReqs": []
                            ])

                            userDoc.setData([
                                "username": lowercased_username,
                                "displayUsername": username,
                                "id": userId,
                            ], merge: true) { err in
                                if let _ = error {
                                    completion(AccountError.uniqueError("Failed to set account info."))
                                } else {
                                    do {
                                        try Auth.auth().signOut()
                                    } catch {
                                        print("- - - - - Sign Out Failed - - - - -")
                                    }
                                    completion(nil)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    public func resetPassword(email: String, completion: @escaping (AccountError?) -> Void) {
        
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                completion(AccountError.propogatedError(error.localizedDescription))
            } else {
                completion(nil)
            }
        }
    }
    
    public func checkUsername(username: String, completion: @escaping (AccountError?) -> Void) {
        
        // Make sure the length of the username is valid
        guard username.count <= 20 else {
            completion(AccountError.usernameTooLong)
            return
        }
        guard username.count > 1 else {
            completion(AccountError.usernameTooShort)
            return
        }
        
        // Make sure the username is formatted correctly
        do {
            try _ = AccountOperations.usernameValid(username: username)
        } catch {
            completion(AccountError.usernameInvalid)
            return
        }
        
        // Make sure the username is available
        let usernamesDoc = self.db.collection("users").document("usernames")
        
        usernamesDoc.getDocument { (docSnap, error) in
            
            if let _ = error {
                completion(AccountError.usernameTaken(username))
            } else if let docSnap = docSnap {
                
                let data = docSnap.data()!
                
                let usernames: [String] = data["usernames"]! as! [String]
                
                if usernames.contains(username.lowercased()) {
                    completion(AccountError.usernameTaken(username))
                } else {
                    completion(nil)
                }
                
            } else {
                completion(AccountError.usernameTaken(username))
            }
        }
    }
    
    private static func usernameValid(username: String) throws -> Bool {
        
        let characters: [Character] = Array(username)
        
        for letter in characters {
            
            if let ascii = letter.asciiValue {
                
                if ascii < 48 || (ascii > 57 && ascii < 65) || (ascii > 90 && ascii < 97) || ascii > 122 {
                    if ascii != 95 {
                        throw AccountError.usernameInvalid
                    }
                }
            } else {
                throw AccountError.usernameInvalid
            }
        }
        
        return true
    }
    
    // - - - - - - - - - - L O G I N - - - - - - - - - - //
    
    public func signInEmail(email: String, password: String, completion: @escaping (AccountError?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { (_, error) in
            if let error = error {
                completion(AccountError.propogatedError(error.localizedDescription))
            } else {
                completion(nil)
            }
        }
    }
    
    // - - - - - - - - - - L O G O U T - - - - - - - - - - //
    
    public func singOut() throws {
        guard Auth.auth().currentUser != nil else { throw AccountError.notLoggedIn }
        do { try Auth.auth().signOut() } catch { throw AccountError.uniqueError("Failed to sign out.") }
    }
    
    // - - - - - - - - - - G E T   A C C O U N T - - - - - - - - - - //
    
    public func getAccountInfo(username: String?, completion: @escaping (AccountModel?, UIImage?, AccountError?) -> Void) {
        
        guard Auth.auth().currentUser != nil else {
            completion(nil, nil, AccountError.notLoggedIn)
            return
        }
        
        if let username = username {
        // Get the id of the user first so that it can be used to get that user's info
            self.getUserId(username: username) { (id, error) in
                if let error = error {
                    completion(nil, nil, error)
                } else if let id = id {
        // Get the user's info using the id
                    self.getAccountInfoID(id: id) { (model, image, accountError) in
                        if let accountError = accountError {
                            completion(nil, nil, accountError)
                        } else if let model = model {
                            completion(model, image, nil)
                        } else {
                            completion(nil, nil, AccountError.uniqueError("Failed to get account info."))
                        }
                    }
                    
                } else {
                    completion(nil, nil, AccountError.userNotFound(username))
                }
            }
            
        } else {
        // The user wants their own info, so just use their own id to find their info
            self.getAccountInfoID(id: Auth.auth().currentUser!.uid) { (model, image, error) in
                if let error = error {
                    completion(model, nil, error)
                } else if let model = model {
                    completion(model, image, nil)
                } else {
                    completion(model, nil, AccountError.uniqueError("Failed to get account info."))
                }
            }
        }
    }
    
    private func getAccountInfoID(id: String, completion: @escaping (AccountModel?, UIImage?, AccountError?) -> Void) {
        
        let userDoc = self.db.collection("users").document(id)
        
        userDoc.getDocument { (docSnap, error) in
            
            if let _ = error {
                completion(nil, nil, AccountError.uniqueError("Failed to get account info."))
            } else if let docSnap = docSnap {
                
                let data = docSnap.data()!
                
                do {
                    
                    let jsonAccount = try JSONSerialization.data(withJSONObject: data)
                    let accountModel: AccountModel = try JSONDecoder().decode(AccountModel.self, from: jsonAccount)
                    
                    AccountProfilePictureManager().getProfilePicture(id: id) { (image, imageError) in
                        if let imageError = imageError {
                            completion(accountModel, nil, imageError)
                        } else if let image = image {
                            completion(accountModel, image, nil)
                        } else {
                            completion(accountModel, nil, AccountError.uniqueError("Failed to download profile picture."))
                        }
                    }
                    
                } catch {
                    completion(nil, nil, AccountError.uniqueError("Failed to decode account info."))
                }
    
            } else {
                completion(nil, nil, AccountError.uniqueError("Failed to get account info."))
            }
        }
    }
    
    // - - - - - - - - - - G E T   U S E R   I D - - - - - - - - - - //
    
    private func getUserId(username: String, completion: @escaping (String?, AccountError?) -> Void) {
        
        let userLookup = self.db.collection("users").document("usernames")
        
        userLookup.getDocument { (docSnap, error) in
            if let _ = error {
                completion(nil, AccountError.userNotFound(username))
            } else if let docSnap = docSnap {
                
                let data = docSnap.data()!
                
                let userIdLookup: [String: String]? = data["userLookup"] as? [String: String]
                
                if let userIdLookup = userIdLookup {
                    completion(userIdLookup[username], nil)
                } else {
                    completion(nil, AccountError.userNotFound(username))
                }
                
            } else {
                completion(nil, AccountError.userNotFound(username))
            }
        }
    }
    
    // - - - - - - - - - - G E T   D I S P L A Y    U S E R N A M E - - - - - - - - - - //
    
    private func getDisplayUsername(username: String, completion: @escaping (String?, AccountError?) -> Void) {
        
        let lowercased_username: String = username.lowercased()
        let userLookup = self.db.collection("users").document("usernames")
        
        userLookup.getDocument { (docSnap, error) in
            if let _ = error {
                completion(nil, .userNotFound(lowercased_username))
            } else if let docSnap = docSnap {
                
                let data = docSnap.data()!
                
                let displayLookup: [String: String]? = data["displayLookup"] as? [String: String]
                
                if let displayLookup = displayLookup {
                    
                    if let displayUsername = displayLookup[lowercased_username] {
                        completion(displayUsername, nil)
                    } else {
                        completion(nil, .userNotFound(lowercased_username))
                    }
                    
                } else {
                    completion(nil, .userNotFound(lowercased_username))
                }
                
            } else {
                completion(nil, .userNotFound(lowercased_username))
            }
        }
    }
    
    // - - - - - - - - - - D E L E T E   A C C O U N T - - - - - - - - - - //
    
    public func deleteAccount(username: String, completion: @escaping (AccountError?) -> Void) {
        
        guard Auth.auth().currentUser != nil else {
            completion(AccountError.notLoggedIn)
            return
        }
        
        let delete_username: String = username.lowercased()
        let userId: String = Auth.auth().currentUser!.uid
    
        let userDoc = db.collection("users").document(userId)
        let usernames = db.collection("users").document("usernames")
        
        Auth.auth().currentUser!.delete { (deleteError) in
            if let _ = deleteError {
                completion(AccountError.uniqueError("Failed to delete account."))
            } else {
                userDoc.delete() { (error) in
                    if let _ = error {
                        completion(AccountError.uniqueError("Failed to delete account."))
                    } else {
                        
                        usernames.updateData([
                            "userLookup": FieldValue.arrayRemove([[delete_username: userId]])
                        ]) { err in
                            if let _ = err {
                                completion(AccountError.uniqueError("Failed to update user lookup after deleting account."))
                            } else {
                                completion(nil)
                            }
                        }
                    }
                }
            }
        }
    }
    
    // - - - - - - - - - - F R I E N D   O P E R A T I O N S - - - - - - - - - - //
    
    public func sendFriendRequest(id: String, username: String, completion: @escaping (AccountError?) -> Void) {
        
        let otherUserDoc = self.db.collection("users").document(id).collection("social").document("friends")
        
        let friendReq = [
            "displayUsername": username,
            "id": Auth.auth().currentUser!.uid,
            "username": username.lowercased()
        ]
        
        otherUserDoc.updateData(["friendReqs": FieldValue.arrayUnion([friendReq])]) { (err) in
            if let _ = err {
                completion(AccountError.uniqueError("Failed to send friend request."))
            } else {
                completion(nil)
            }
        }
    }
    
    public func sendFriendRequest(username: String, invitee_username: String, completion: @escaping (AccountError?) -> Void) {
        
        guard Auth.auth().currentUser != nil else {
            completion(AccountError.notLoggedIn)
            return
        }
        
        // Make sure the user is not friend requesting themself
        guard username.lowercased() != invitee_username.lowercased() else {
            completion(AccountError.selfFriendReq)
            return
        }
        
        self.getUserId(username: invitee_username.lowercased()) { (id, idError) in
            if let idError = idError {
                completion(idError)
            } else if let id = id {
                
                self.sendFriendRequest(id: id, username: username) { error in
                    completion(error)
                }
                
            } else {
                completion(AccountError.userNotFound(invitee_username))
            }
        }
    }
    
    public func respondFriendRequest(id: String, username: String, invitee_username: String, accept: Bool, completion: @escaping (AccountError?) -> Void) {
        
        guard Auth.auth().currentUser != nil else {
            completion(AccountError.notLoggedIn)
            return
        }
        
        // Use the other user's id & the current user's id to respond to the request
        let userDoc = self.db.collection("users").document(Auth.auth().currentUser!.uid).collection("social").document("friends")
        let otherUserDoc = self.db.collection("users").document(id).collection("social").document("friends")
        
        let userInvite = [
            "displayUsername": invitee_username,
            "id": id,
            "username": invitee_username.lowercased()
        ]
        
        let otherUserInvite = [
            "displayUsername": username,
            "id": Auth.auth().currentUser!.uid,
            "username": username.lowercased()
        ]
                
        if accept {
        
        // Accept the friend request
            userDoc.updateData([
                "friends": FieldValue.arrayUnion([userInvite]),
                "friendReqs": FieldValue.arrayRemove([userInvite])
            ]) { (acceptError) in
                if let _ = acceptError {
                    completion(AccountError.failedAcceptFriendReq(invitee_username))
                } else {
                    otherUserDoc.updateData([
                        "friends": FieldValue.arrayUnion([otherUserInvite]),
                    ]) { (err) in
                        if let _ = err {
                            completion(AccountError.failedAcceptFriendReq(invitee_username))
                        } else {
                            completion(nil)
                        }
                    }
                }
            }
        } else {
                 
        // Reject the friend request
            userDoc.updateData(["friendReqs": FieldValue.arrayRemove([userInvite])]) { (acceptError) in
                if let _ = acceptError {
                    completion(AccountError.failedAcceptFriendReq(invitee_username))
                } else {
                    completion(nil)
                }
            }
        }
    }
    
    public func removeFriend(id: String, username: String, friend_username: String, completion: @escaping (AccountError?) -> Void) {
        
        guard Auth.auth().currentUser != nil else {
            completion(AccountError.notLoggedIn)
            return
        }
        
        let userDoc = self.db.collection("users").document(Auth.auth().currentUser!.uid).collection("social").document("friends")
        let otherUserDoc = self.db.collection("users").document(id).collection("social").document("friends")
        
        let userFriend = [
            "displayUsername": friend_username,
            "id": id,
            "username": friend_username.lowercased()
        ]
        
        let otherUserFriend = [
            "displayUsername": username,
            "id": Auth.auth().currentUser!.uid,
            "username": username.lowercased()
        ]
        
    // Remove each account from one another's friends list
        userDoc.updateData(["friends": FieldValue.arrayRemove([userFriend])]) { (sendError) in
            if let _ = sendError {
                completion(AccountError.uniqueError("Failed to remove friend."))
            } else {
                otherUserDoc.updateData(["friends": FieldValue.arrayRemove([otherUserFriend])]) { (err) in
                    if let _ = err {
                        completion(AccountError.uniqueError("Failed to remove friend."))
                    } else {
                        completion(nil)
                    }
                }
            }
        }
    }
    
    // - - - - - - - - - - G A M E   I N V I T E   O P E R A T I O N S - - - - - - - - - - //
    
    public func sendGameInvite(players: [String], from: String, gameId: String, completion: @escaping (AccountError?) -> Void) {
        
        guard Auth.auth().currentUser != nil else {
            completion(AccountError.notLoggedIn)
            return
        }
        
        let userDoc = self.db.collection("users").document(Auth.auth().currentUser!.uid)
        
        userDoc.updateData(["games": FieldValue.arrayUnion([gameId])]) { _ in
            self.sendGameInvites(players: players, from: from, gameId: gameId) { (error) in
                completion(error)
            }
        }
    }
    
    private func sendGameInvites(players: [String], from: String, gameId: String, completion: @escaping (AccountError?) -> Void) {
        
        guard !players.isEmpty else {
            completion(nil)
            return
        }
        
        var temp_players = players
        let user = temp_players.removeLast()
        
        self.getUserId(username: user) { (id, idError) in
            if let idError = idError {
                completion(idError)
            } else if let id = id {
                
                let userDoc = self.db.collection("users").document(id)
                
                userDoc.updateData([
                    "gameReq": ["from": from, "gameId": gameId]
                ]) { (error) in
                    if let _ = error {
                        completion(AccountError.failedSendGameReq(user))
                    } else {
                        return self.sendGameInvites(players: temp_players, from: from, gameId: gameId) { (reError) in
                            if let reError = reError {
                                completion(reError)
                            } else {
                                completion(nil)
                            }
                        }
                    }
                }
                
            } else {
                completion(AccountError.userNotFound(user))
            }
        }
    }
    
    // Lots of duplicated code in this function. Investigate further to improve
    public func respondGameRequest(username: String, gameId: String, from: String, accept: Bool, completion: @escaping (AccountError?) -> Void) {
        
        let gameOperations: GameOperations = GameOperations()
        
        guard Auth.auth().currentUser != nil else {
            completion(AccountError.notLoggedIn)
            return
        }
        
        let userDoc = self.db.collection("user").document(Auth.auth().currentUser!.uid)
        let gameDoc = self.db.collection("games").document(gameId)
        
        if accept {
            
            userDoc.updateData([
                "gameReq": FieldValue.arrayRemove([["from": from, "gameId": gameId]]),
                "games": FieldValue.arrayUnion([gameId])
            ]) { (error) in
                if let _ = error {
                    completion(AccountError.uniqueError("Failed to respond to game invite."))
                } else {
                    
                    if accept {
                        
                        gameOperations.acceptGameInvite(id: Auth.auth().currentUser!.uid, gameId: gameId) { acceptReqError in
                            if let acceptReqError = acceptReqError {
                                completion(AccountError.propogatedError(acceptReqError.localizedDescription))
                            } else {
                                completion(nil)
                            }
                        }
                        
                    } else { 
                        
                        gameDoc.updateData([
                            "waitingFor": FieldValue.arrayRemove([Auth.auth().currentUser!.uid]),
                            "quit": FieldValue.arrayUnion([Auth.auth().currentUser!.uid])
                        ]) { (err) in
                            if let _ = err {
                                completion(AccountError.uniqueError("Failed to update game state."))
                            } else {
                                completion(nil)
                            }
                        }
                    }
                }
            }
            
        } else {
            
            userDoc.updateData(["gameReq": FieldValue.arrayRemove([["from": from, "gameId": gameId]])]) { error in
                if let _ = error {
                    completion(AccountError.uniqueError("Failed to respond to game invite."))
                } else {
                    
                    if accept {
                        
                        gameDoc.updateData([
                            "waitingFor": FieldValue.arrayRemove([Auth.auth().currentUser!.uid]),
                        ]) { (err) in
                            if let _ = err {
                                completion(AccountError.uniqueError("Failed to update game state."))
                            }
                        }
                        
                    } else {
                        
                        gameDoc.updateData([
                            "waitingFor": FieldValue.arrayRemove([Auth.auth().currentUser!.uid]),
                            "quit": FieldValue.arrayUnion([Auth.auth().currentUser!.uid])
                        ]) { (err) in
                            if let _ = err {
                                completion(AccountError.uniqueError("Failed to update game state."))
                            }
                        }
                    }
                }
            }
        }
    }
    
    public func leaveGame(completion: @escaping (AccountError) -> Void) {
        
    }
    
    
    // - - - - - - - - - - G E T   G A M E   L I S T   I T E M S - - - - - - - - - - //
    
    /*
     When Games & Friends are displayed to a user the app needs the username & profile picture of other relevant users
     Parameters:        An array of user ids
     Returns:           An array of UserModel & An array of profile pictures
     */
    
    
}
