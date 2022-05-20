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
                    
                    // Add their info to the DB
                    let userDoc = db.collection("users").document(Auth.auth().currentUser!.uid)
                    
                    let usernameStuff: [String: String] = [
                        "username": username.lowercased(),
                        "displayUsername": username
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
    
    public func checkUsername(username: String, completion: @escaping (AccountErrorType?) -> Void) {
        
        // Make sure the length of the username is valid
        guard username.count <= 20 else {
            completion(AccountErrorType(error: .usernameTooLong))
            return
        }
        guard username.count > 1 else {
            completion(AccountErrorType(error: .usernameTooShort))
            return
        }
        
        // Make sure the username is formatted correctly
        do {
            try _ = AccountOperations.usernameValid(username: username)
        } catch {
            completion(AccountErrorType(error: .usernameInvalid))
            return
        }
        
        // Make sure the username is available
        let usernamesDoc = self.db.collection("users").document("usernames")
        
        usernamesDoc.getDocument { (docSnap, error) in
            
            if let _ = error {
                completion(AccountErrorType(error: .usernameTaken(username)))
            } else if let docSnap = docSnap {
                
                let data = docSnap.data()!
                
                let usernames: [String] = data["usernames"]! as! [String]
                
                if usernames.contains(username.lowercased()) {
                    completion(AccountErrorType(error: .usernameTaken(username)))
                } else {
                    completion(nil)
                }
                
            } else {
                completion(AccountErrorType(error: .usernameTaken(username)))
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
    
    public func signInEmail(email: String, password: String, completion: @escaping (AccountErrorType?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { (_, error) in
            DispatchQueue.main.async {
                if let error = error {
                    completion(AccountErrorType(error: .propogatedError(error.localizedDescription)))
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
    
    // - - - - - - - - - - G E T  A C C O U N T - - - - - - - - - - //
    
    public func getAccountInfo(completion: @escaping (AccountModel?, AccountError?) -> Void) {
        
        guard Auth.auth().currentUser != nil else {
            completion(nil, AccountError.notLoggedIn)
            return
        }
        
        let userDoc = self.db.collection("users").document(Auth.auth().currentUser!.uid)
        
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
    
    // - - - - - - - - - - D E L E T E  A C C O U N T - - - - - - - - - - //
    
    public func deleteAccount(completion: @escaping (AccountError?) -> Void) throws {
        
        guard Auth.auth().currentUser != nil else { throw AccountError.notLoggedIn }
        
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
