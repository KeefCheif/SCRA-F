//
//  MenuManagerViewModel.swift
//  SCRA-F
//
//  Created by KeefCheif on 6/21/22.
//

import Foundation
import Firebase
import SwiftUI

class MenuViewModel: ObservableObject {
    
    @Published var isLoading: Bool = false
    @Published var gamesIsLoading: Bool = false
    
    @Published var account_model: AccountModel = AccountModel()
    @Published var friend_model: FriendListModel = FriendListModel()
    @Published var game_model: GameListModel?
    
    @Published var profile_picture: UIImage?
    
    @Published var account_error: AccountErrorType?
    @Published var friends_error: AccountError?
    
    private var momoized_profile_pics: [String: (Bool, UIImage?)] = [String: (Bool, UIImage?)]()
    
    private let accountManager: AccountOperations = AccountOperations()
    private let profilePictureManager: AccountProfilePictureManager = AccountProfilePictureManager()
    private var listener: ListenerRegistration?
    
    
    
    init() {
        // Attatch the listener to update the UI to changes made to the users info in the DB
        self.attatchListener()
    }
    
    private func attatchListener() {
        
        guard let currentuser = Auth.auth().currentUser else {
            self.account_error = AccountErrorType(error: .notLoggedIn)
            return
        }
        
        let db = Firestore.firestore()
        let docRef = db.collection("users").document(currentuser.uid)
        
        self.listener = docRef.addSnapshotListener(includeMetadataChanges: false) { [unowned self] (docSnap, error) in
            if let error = error {
                print("Attatch Listener Error:")
                print(error.localizedDescription)
            } else if let docSnap = docSnap {
                
                let data = docSnap.data()!
                
                do {
                    
                    // Convert response from DB into the model
                    let decoder = JSONDecoder()
                    let jsonAccount = try JSONSerialization.data(withJSONObject: data)
                    self.account_model = try decoder.decode(AccountModel.self, from: jsonAccount)
                    
                    // Get the user's profile picture & save it
                    if let profile_pic = self.momoized_profile_pics[self.account_model.id] {
                        self.profile_picture = profile_pic.1
                    } else {
                        self.profilePictureManager.getProfilePicture(id: nil) { [unowned self] (pic, _) in
                            self.profile_picture = pic
                            self.momoized_profile_pics[self.account_model.id] = (true, pic)
                        }
                    }
                    
                    // Prepare Friend & FriendReq info
                    self.refreshFriendList()
                    
                    // Prepare Game & GameReq info
                    
                    
                } catch {
                    print("DECODER ERROR")
                }
            }
        }
    }
    
    
    // - - - - - - - - - - F R I E N D   F U N C T I O N S - - - - - - - - - - //
    
    public func friendRequest(invitee_usernmae: String, completion: @escaping (AccountError?) -> Void) {
        
        guard invitee_usernmae.count >= 2 else {
            completion(.uniqueError("Please enter a valid username."))
            return
        }
        
        for friend in self.friend_model.friends {
            guard friend.displayUsername.lowercased() != invitee_usernmae.lowercased() else {
                completion(.alreadyFriends)
                return
            }
        }
        
        self.accountManager.sendFriendRequest(username: self.account_model.displayUsername, invitee_username: invitee_usernmae) { error in
            completion(error)
        }
    }
    
    public func respondFriendRequest(id: String, invitee_username: String, accept: Bool) {
        
        self.accountManager.respondFriendRequest(id: id, username: self.account_model.displayUsername, invitee_username: invitee_username, accept: accept) { error in
            if let error = error {
                self.account_error = AccountErrorType(error: error)
            }
        }
    }
    
    public func removeFriend(id: String, friend_username: String) {
        self.accountManager.removeFriend(id: id, username: self.account_model.displayUsername, friend_username: friend_username) { error in
            
        }
    }
    
    private func refreshFriendList() {
        
        // Refresh the Friend Requests
        var refreshReqs: [UserModel] = [UserModel]()
        var newLookup: [String: Int] = [String: Int]()
        
        if let friendReqs = self.account_model.friendReq {
            for (count, friendReq) in friendReqs.enumerated() {
                
                if let index = self.friend_model.friendReqLookup[friendReq.id] {
                    refreshReqs.append(self.friend_model.friendReqs[index])
                } else {
                    refreshReqs.append(UserModel(id: friendReq.id, displayUsername: friendReq.displayUsername))
                }
                
                newLookup[friendReq.id] = count
            }
        }
        
        // Refresh the Friends
        var refreshFriends: [UserModel] = [UserModel]()
        var newFriendLookup: [String: Int] = [String: Int]()
        
        if let friends = self.account_model.friends {
            for (count, friend) in friends.enumerated() {
                
                if let index = self.friend_model.friendLookup[friend.id] {
                    refreshFriends.append(self.friend_model.friends[index])
                } else {
                    refreshFriends.append(UserModel(id: friend.id, displayUsername: friend.displayUsername))
                }
                
                newFriendLookup[friend.id] = count
            }
        }
        
        // Make the changes
        self.friend_model.friendReqs = refreshReqs
        self.friend_model.friendReqLookup = newLookup
        self.friend_model.friends = refreshFriends
        self.friend_model.friendLookup = newFriendLookup
        
        // Get the Friend Request's profile pictures
        for i in 0..<self.friend_model.friendReqs.count {
            
            let id: String = self.friend_model.friendReqs[i].id
            
            if let picture_info = self.momoized_profile_pics[id] {
                self.friend_model.friendReqs[i].profilePicture = picture_info.1
            } else {
                self.profilePictureManager.getProfilePicture(id: id) { [unowned self] (picture, _) in
                    
                    DispatchQueue.main.async {
                        self.friend_model.friendReqs[i].profilePicture = picture
                    }
                    
                    self.momoized_profile_pics[id] = (true, picture)
                }
            }
        }
        
        // Get the Friend's profile pictures
        for i in 0..<self.friend_model.friends.count {
            
            let id: String = self.friend_model.friends[i].id
            
            if let picture_info = self.momoized_profile_pics[id] {
                self.friend_model.friends[i].profilePicture = picture_info.1
            } else {
                self.profilePictureManager.getProfilePicture(id: id) { [unowned self] (picture, _) in
                    
                    DispatchQueue.main.async {
                        self.friend_model.friends[i].profilePicture = picture
                    }
                    
                    self.momoized_profile_pics[id] = (true, picture)
                }
            }
        }
    }
    
    
    
    // - - - - - - - - - - G A M E   F U N C T I O N S - - - - - - - - - - //
    
    private func refreshGameList() {
        
        
        
    }
    
    
    public func logout(loggedIn: inout Bool) {
        
        do {
            try self.accountManager.singOut()
            loggedIn = false
        } catch {
            loggedIn = false
        }
    }
    
    public func changeProfilePicture(picture: UIImage?) {
        
        guard picture != nil else { return }
        
        //let hasFlag: Bool = self.profile_picture != nil
        self.profile_picture = picture
        
        self.profilePictureManager.uploadProfilePicture(image: picture!) { error in
            if let error = error {
                self.account_error = AccountErrorType(error: error)
            }
        }
    }

}
