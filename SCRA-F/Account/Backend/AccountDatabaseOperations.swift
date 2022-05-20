//
//  AccountDatabaseOperations.swift
//  SCRA-F
//
//  Created by KeefCheif on 5/18/22.
//

import Firebase
import FirebaseAuth

struct AccountOperations {
    
    private let db = Firestore.firestore()
    
    // - - - - - - - - - - R E G I S T E R - - - - - - - - - - //
    
    public func createAccount(username: String, email: String, password: String, completion: @escaping (AccountError?) -> Void) {
        
        Auth.auth().createUser(withEmail: email, password: password) { (_, error) in
            DispatchQueue.main.async {
                if let error = error {
                    completion(AccountError.propogatedError(error.localizedDescription))
                } else {
                    
                    let userId: String = Auth.auth().currentUser!.uid
                    
                    // Add the new user's info to the general user lookup section in the DB so that they can easily be found and enforce that there are no duplicate usernames made
                    let userLookup = self.db.collection("users").document("usernames")
                    let userDoc = db.collection("users").document(userId)
                    
                    userLookup.updateData([
                        "userLookup": FieldValue.arrayUnion([[username: userId]]),
                        "usernames": FieldValue.arrayUnion([username])
                    ]) { (userLookupError) in
                        
                        if let _ = userLookupError {
                            completion(AccountError.uniqueError("Failed to set user lookup info."))
                        } else {
                            
                            let usernameStuff: [String: Any] = [
                                "username": username.lowercased(),
                                "displayUsername": username,
                                "hasProfilePicture": false
                            ]
                            
                            userDoc.setData(usernameStuff, merge: true) { err in
                                if let _ = error {
                                    completion(AccountError.uniqueError("Failed to set account info."))
                                } else {
                                    do { try Auth.auth().signOut() } catch { print("- - - - - Sign Out Failed - - - - -") }
                                    completion(nil)
                                }
                            }
                        }
                    }
                }
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
            DispatchQueue.main.async {
                if let error = error {
                    completion(AccountError.propogatedError(error.localizedDescription))
                } else {
                    completion(nil)
                }
            }
        }
    }
    
    // - - - - - - - - - - L O G O U T - - - - - - - - - - //
    
    public func singOut() throws {
        guard Auth.auth().currentUser != nil else { throw AccountError.notLoggedIn }
        do { try Auth.auth().signOut() } catch { throw AccountError.uniqueError("Failed to sign out.") }
    }
    
    // - - - - - - - - - - G E T   A C C O U N T - - - - - - - - - - //
    
    public func getAccountInfo(username: String?, completion: @escaping (AccountModel?, AccountError?) -> Void) {
        
        guard Auth.auth().currentUser != nil else {
            completion(nil, AccountError.notLoggedIn)
            return
        }
        
        if let username = username {
        // Get the id of the user first so that it can be used to get that user's info
            self.getUserId(username: username) { (id, error) in
                if let error = error {
                    completion(nil, error)
                } else if let id = id {
        // Get the user's info using the id
                    self.getAccountInfoID(id: id) { (model, accountError) in
                        if let accountError = accountError {
                            completion(nil, accountError)
                        } else if let model = model {
                            completion(model, nil)
                        } else {
                            completion(nil, AccountError.uniqueError("Failed to get account info."))
                        }
                    }
                    
                } else {
                    completion(nil, AccountError.userNotFound(username))
                }
            }
            
        } else {
        // The user wants their own info, so just use their own id to find their info
            self.getAccountInfoID(id: Auth.auth().currentUser!.uid) { (model, error) in
                if let error = error {
                    completion(nil, error)
                } else if let model = model {
                    completion(model, nil)
                } else {
                    completion(nil, AccountError.uniqueError("Failed to get account info."))
                }
            }
        }
    }
    
    private func getAccountInfoID(id: String, completion: @escaping (AccountModel?, AccountError?) -> Void) {
        
        let userDoc = self.db.collection("users").document(id)
        
        userDoc.getDocument { (docSnap, error) in
            
            if let _ = error {
                completion(nil, AccountError.uniqueError("Failed to get account info."))
            } else if let docSnap = docSnap {
                
                let data = docSnap.data()!
                
                let username: String = data["username"] as! String
                let displayUsername: String = data["displayUsername"] as! String
                let hasProfilePicture: Bool = data["hasProfilePicture"] as? Bool ?? false
                
                if hasProfilePicture {
                    
                    AccountProfilePictureManager().getProfilePicture() { (image, imageError) in
                        
                        if let imageError = imageError {
                            completion(nil, imageError)
                        } else if let image = image {
                            completion(AccountModel(displayUsername: displayUsername, username: username, hasProfilePicture: true, profilePicture: image), nil)
                        } else {
                            completion(nil, AccountError.uniqueError("Failed to download profile picture."))
                        }
                    }
                    
                } else {
                    completion(AccountModel(displayUsername: displayUsername, username: username, hasProfilePicture: false, profilePicture: nil), nil)
                }
                
            } else {
                completion(nil, AccountError.uniqueError("Failed to get account info."))
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
                    completion(nil, nil)
                }
                
            } else {
                completion(nil, AccountError.userNotFound(username))
            }
        }
    }
    
    // - - - - - - - - - - D E L E T E   A C C O U N T - - - - - - - - - - //
    
    public func deleteAccount(completion: @escaping (AccountError?) -> Void) {
        
        guard Auth.auth().currentUser != nil else {
            completion(AccountError.notLoggedIn)
            return
        }
    
        let userDoc = db.collection("users").document(Auth.auth().currentUser!.uid)
        
        Auth.auth().currentUser!.delete { (deleteError) in
            if let _ = deleteError {
                completion(AccountError.uniqueError("Failed to delete account."))
            } else {
                userDoc.delete() { (error) in
                    if let _ = error {
                        completion(AccountError.uniqueError("Failed to delete account."))
                    } else {
                        completion(nil)
                    }
                }
            }
        }
    }

}
