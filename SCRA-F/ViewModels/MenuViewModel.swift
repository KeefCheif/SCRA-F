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
    
    @Published var account_model: MenuAccountModel?
    @Published var friends_model: MenuAccountFriendModel = MenuAccountFriendModel(friends: [MenuAccountModel](), friendReqs: [MenuAccountModel]())
    @Published var games_model: MenuAccountGamesModel?
    
    @Published var account_error: AccountError?
    
// - - - - - S E R V E R   M A N A G E R S - - - - - //
    private let accountManager: AccountOperations = AccountOperations()
    private let profilePictureManager: AccountProfilePictureManager = AccountProfilePictureManager()
    
// - - - - - L I S T E N E R S - - - - - //
    private var friendsListener: ListenerRegistration?
    private var gamesListener: ListenerRegistration?
    
// - - - - - P R O F I L E   P I C S - - - - - //
    private var memoized_pics: [String: (Bool, UIImage?)] = [String: (Bool, UIImage?)]()
    
    
    
    
    
    init() {
        
        guard Auth.auth().currentUser != nil else {
            self.account_error = .notLoggedIn
            return
        }
        
        // Get general Account info first
        self.accountManager.getAccountInfo(username: nil) { [unowned self]  (accountModel, profile_pic, error) in
            
            if let accountModel = accountModel {
                
                self.account_model = MenuAccountModel(id: accountModel.id, displayUsername: accountModel.displayUsername, username: accountModel.username, profile_picture: profile_pic)
                
                // Attatch subscribers & get social info
                self.attatchFriendListener()
                
            } else {
                self.account_error = error
            }
        }
    }
    
    private func attatchFriendListener() {
        
        let friendDoc = Firestore.firestore().collection("users").document(Auth.auth().currentUser!.uid).collection("social").document("friends")
        
        self.friendsListener = friendDoc.addSnapshotListener(includeMetadataChanges: false) { [unowned self] (docSnap, error) in
            
            if let docSnap = docSnap {
                
                let data = docSnap.data()!
                
                do {
                    
                    let jsonFriends = try JSONSerialization.data(withJSONObject: data)
                    let friendsModel: AccountFriendsModel = try JSONDecoder().decode(AccountFriendsModel.self, from: jsonFriends)
                    
                    self.getFriendImages(newFriendsModel: friendsModel)
                    
                } catch {
                    
                }
                
            } else {
                
            }
        }
    }
    
    private func attatchGameListener() {
        
        let gameDoc = Firestore.firestore().collection("users").document(Auth.auth().currentUser!.uid).collection("social").document("games")
        
        self.gamesListener = gameDoc.addSnapshotListener(includeMetadataChanges: false) { (docSnap, error) in
            
            if let docSnap = docSnap {
                
                let data = docSnap.data()!
                
                do {
                    
                    let jsonGames = try JSONSerialization.data(withJSONObject: data)
                    let gamesModel: AccountGamesModel = try JSONDecoder().decode(AccountGamesModel.self, from: jsonGames)
                    
                    // Populate the games model right now so the user does not have to wait for the profile pics to interact with the app
                    if self.games_model == nil {
                        self.games_model = MenuAccountGamesModel(games: gamesModel.games.map { MenuAccountGameModel(players: $0.players.map { MenuAccountModel(id: $0.id, displayUsername: $0.displayUsername, username: $0.username) }, scores: $0.scores, turn: $0.turn, gameType: $0.gameType) }, gameReqs: gamesModel.gameReqs.map { MenuAccountGameReqModel(players: $0.players.map { MenuAccountModel(id: $0.id, displayUsername: $0.displayUsername, username: $0.username) }, gameType: $0.gameType) })
                    }
                    
                    // Get profile Pics for games
                    
                    
                } catch {
                    
                }
                
            } else {
                
            }
        }
    }
    
    
    private func getFriendImages(newFriendsModel: AccountFriendsModel) {
        
        // Step 1: Prepare two arrays each for friends and friendsReqs: a finished and unfinished array
                    // The finished array contians user info including their profile pic if they have one
                    // The unfinished array contains only user info and no profile pic yet
        
        // Step 2: Populate the model so that the user can interact with the app without having to wait for profile pictures to download
        
        // Step 3: Get the profile pictures starting from the index of the unfinished users (DO NOT touch the finished users)
        
        // ~ Step 1 ~ //
        
        // Do the Friend Reqs first sine they appear at the top of the screen
        var finishedFriendReqs: [MenuAccountModel] = [MenuAccountModel]()
        var unfinishedFriendReqs: [MenuAccountModel] = [MenuAccountModel]()
        
        for friendReq in newFriendsModel.friendReqs {
            
            if let pic_info = self.memoized_pics[friendReq.id] {
                // The profile pic of this user was found, so it goes in the finished array
                finishedFriendReqs.append(MenuAccountModel(id: friendReq.id, displayUsername: friendReq.displayUsername, username: friendReq.username, profile_picture: pic_info.1))
            } else {
                // There was no profile pic found for this user, so it goes in the unfinished array
                unfinishedFriendReqs.append(MenuAccountModel(id: friendReq.id, displayUsername: friendReq.displayUsername, username: friendReq.username))
            }
        }
        
        // Repeat the above process for the friends
        var finishedFriends: [MenuAccountModel] = [MenuAccountModel]()
        var unfinishedFriends: [MenuAccountModel] = [MenuAccountModel]()
        
        for friend in newFriendsModel.friends {
            
            if let pic_info = self.memoized_pics[friend.id] {
                finishedFriends.append(MenuAccountModel(id: friend.id, displayUsername: friend.displayUsername, username: friend.username, profile_picture: pic_info.1))
            } else {
                unfinishedFriends.append(MenuAccountModel(id: friend.id, displayUsername: friend.displayUsername, username: friend.username))
            }
        }
        
        // ~ Step 2 ~ //
         
        // Populate/Update the model
        self.friends_model = MenuAccountFriendModel(friends: finishedFriends + unfinishedFriends, friendReqs: finishedFriendReqs + unfinishedFriendReqs)
        
        // ~ Step 3 ~ //
        
        // Get the profile pictures of the unfinished friendReqs first since friendReqs are displayed at the to of the screen
        for i in finishedFriendReqs.count..<self.friends_model.friendReqs.count {
            
            let id: String = self.friends_model.friendReqs[i].id
            
            // It's possible that one of the pictures in the unfinished section is now memoized due to them being downloaded asyncronously
            if let pic = self.memoized_pics[id] {
                self.friends_model.friendReqs[i].profile_picture = pic.1
            } else {
                self.profilePictureManager.getProfilePicture(id: self.friends_model.friendReqs[i].id) { [unowned self] (pic, _) in
                    self.friends_model.friendReqs[i].profile_picture = pic
                    self.memoized_pics[id] = (pic != nil, pic)
                }
            }
        }
        
        // Repeat the above process for unfinished friends
        for i in finishedFriends.count..<self.friends_model.friends.count {
            
            let id: String = self.friends_model.friends[i].id
            
            if let pic = self.memoized_pics[id] {
                self.friends_model.friends[i].profile_picture = pic.1
            } else {
                self.profilePictureManager.getProfilePicture(id: id) { [unowned self] (pic, _) in
                    self.friends_model.friends[i].profile_picture = pic
                    self.memoized_pics[id] = (pic != nil, pic)
                }
            }
        }
    }
    
    
// - - - - - - - - - - A C C O U N T    M A N A G E M E N T - - - - - - - - - - //
    
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
        self.account_model!.profile_picture = picture
        
        self.profilePictureManager.uploadProfilePicture(image: picture!) { error in
            self.account_error = error
        }
    }
    

// - - - - - - - - - - F R I E N D    M A N A G E M E N T - - - - - - - - - - //
    
    public func friendRequest(invitee_usernmae: String, completion: @escaping (AccountError?) -> Void) {
        
        let lowercased_invitee_user: String = invitee_usernmae.lowercased()
        
        // Make sure the username is valid
        guard invitee_usernmae.count >= 2 else {
            completion(.uniqueError("Please enter a valid username."))
            return
        }
        
        // Make sure they are not friends already
        for friend in self.friends_model.friends {
            guard friend.username != lowercased_invitee_user else {
                completion(.alreadyFriends)
                return
            }
        }
        
        // Make sure they do not have a request from this user
        for friendReq in self.friends_model.friendReqs {
            guard friendReq.username != lowercased_invitee_user else {
                completion(.alreadyFriendRequest)
                return 
            }
        }
        
        self.accountManager.sendFriendRequest(username: self.account_model!.displayUsername, invitee_username: invitee_usernmae) { error in
            completion(error)
        }
    }
    
    public func respondFriendRequest(id: String, invitee_username: String, accept: Bool) {
        
        self.accountManager.respondFriendRequest(id: id, username: self.account_model!.displayUsername, invitee_username: invitee_username, accept: accept) { error in
            self.account_error = error
        }
    }
    
    public func removeFriend(id: String, friend_username: String) {
        self.accountManager.removeFriend(id: id, username: self.account_model!.displayUsername, friend_username: friend_username) { error in
            
        }
    }
}
