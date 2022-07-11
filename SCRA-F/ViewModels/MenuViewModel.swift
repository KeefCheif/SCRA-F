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
    
    @Published var isLoading: Bool = true
    @Published var gamesIsLoading: Bool = false
    
    @Published var account_model: AccountModel = AccountModel()
    @Published var friend_model: FriendListModel = FriendListModel()
    @Published var game_model: GameListModel?
    
    @Published var profile_picture: UIImage?
    
    @Published var account_error: AccountErrorType?
    
    private var memoized_users: Set<String> = Set<String>()
    
    private let accountManager: AccountOperations = AccountOperations()
    private let profilePictureManager: AccountProfilePictureManager = AccountProfilePictureManager()
    private var listener: ListenerRegistration?
    
    init() {
        
        self.accountManager.getAccountInfo(username: nil) { [unowned self] (profile, picture, error) in
            
            if let error = error {
                self.account_error = AccountErrorType(error: error)
            } else if let profile = profile {
                
                self.account_model = profile
                self.profile_picture = picture
                
                self.refreshFriendList(doFriends: true, doFriendReqs: true)
                
                self.isLoading = false
                self.attatchListener()
                
                
            } else {
                self.account_error = AccountErrorType(error: .uniqueError("Failed to get account info."))
            }
            
            //self.isLoading = false
        }
    }
    
    deinit {
        if let listener = self.listener {
            listener.remove()
        }
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
                    
                    let decoder = JSONDecoder()
                    
                    let jsonAccount = try JSONSerialization.data(withJSONObject: data)
                    let accountModel = try decoder.decode(AccountModel.self, from: jsonAccount)
                    
                    self.account_model = accountModel
                    
                    // Check the new accont model (accountModel) for changes & refresh the view model accordingly
                    // TO DO
                    
                } catch {
                    
                }
            }
        }
    }
    
    // - - - - - - - - - - F R I E N D   F U N C T I O N S - - - - - - - - - - //
    
    public func friendRequest(invitee_usernmae: String, completion: @escaping () -> Void) {
        
        guard invitee_usernmae.count >= 2 else {
            completion()
            return
        }
        
        self.accountManager.sendFriendRequest(username: self.account_model.username, invitee_username: invitee_usernmae) { error in
            if let error = error {
                self.account_error = AccountErrorType(error: error)
            }
            completion()
        }
    }
    
    public func respondFriendRequest(id: String, invitee_username: String, accept: Bool) {
        
        self.accountManager.respondFriendRequest(id: id, username: self.account_model.username, invitee_username: invitee_username, accept: accept) { error in
            if let error = error {
                self.account_error = AccountErrorType(error: error)
            }
        }
    }
    
    public func removeFriend(id: String, friend_username: String) {
        self.accountManager.removeFriend(id: id, username: self.account_model.displayUsername, friend_username: friend_username) { error in
            
        }
    }
    
    
    public func logout(loggedIn: inout Bool) {
        
        do {
            try self.accountManager.singOut()
            loggedIn = false
        } catch {
            loggedIn = false
        }
    }
    
    public func changeProfilePicture(picture1: UIImage?) {
        
        guard picture1 != nil else { return }
        
        let picture: UIImage? = UIImage(named: "Beluga")
        
        if self.account_model.hasProfilePicture {
            self.profilePictureManager.changeProfilePicture(image: picture!) { error in
                if let error = error {
                    self.account_error = AccountErrorType(error: error)
                } else {
                    self.profilePictureManager.getProfilePicture(id: nil) { (image, imageError) in
                        if let image = image {
                            self.profile_picture = image
                        }
                    }
                }
            }
        } else {
            self.profilePictureManager.uploadProfilePicture(image: picture!) { error in
                if let error = error {
                    self.account_error = AccountErrorType(error: error)
                } else {
                    self.profilePictureManager.getProfilePicture(id: nil) { (image, imageError) in
                        if let image = image {
                            self.profile_picture = image
                        }
                    }
                }
            }
        }
    }
    
    
    private func refreshFriendList(doFriends: Bool, doFriendReqs: Bool) {
        
        if doFriends {
            var refreshedFriends: [UserModel] = [UserModel]()
            
            if let friends = self.account_model.friends {
                for friend in friends {
                    refreshedFriends.append(UserModel(id: friend.id, displayUsername: friend.displayUsername))
                }
            }
            
            self.friend_model.friends = refreshedFriends
            
            self.getProfilePictures(users: refreshedFriends, returnUsers: [UserModel]()) { (friends, error) in
                if let friends = friends {
                    self.friend_model.friends = friends
                }
            }
        }
        
        if doFriendReqs {
            var refreshedFriendReqs: [UserModel] = [UserModel]()
            
            if let friendReqs = self.account_model.friendReq {
                for friendReq in friendReqs {
                    refreshedFriendReqs.append(UserModel(id: friendReq.id, displayUsername: friendReq.displayUsername))
                }
            }
            
            self.friend_model.friendReqs = refreshedFriendReqs
            
            self.getProfilePictures(users: refreshedFriendReqs, returnUsers: [UserModel]()) { (friendReqs, error) in
                if let friendReqs = friendReqs {
                    self.friend_model.friendReqs = friendReqs
                }
            }
        }
    }
    
    
    private func getProfilePictures(users: [UserModel], returnUsers: [UserModel], completion: @escaping ([UserModel]?, AccountError?) -> Void) {
        
        guard !users.isEmpty else {
            completion(returnUsers, nil)
            return
        }
        
        var new_users: [UserModel] = users
        
        var current_user: UserModel = new_users.removeLast()
        
        if !self.memoized_users.contains(current_user.id) {
            
            self.memoized_users.insert(current_user.id)
            
            self.profilePictureManager.getProfilePicture(id: current_user.id) { (image, error) in
                
                current_user.profilePicture = image
                
                self.getProfilePictures(users: new_users, returnUsers: returnUsers + [current_user]) { (users, re_error) in
                    completion(users, re_error)
                }
            }
        }
    }
    
}



















/*
private func refreshGameList() {
    
    self.gamesIsLoading = true
    
    self.game_model = GameListModel()
    
    var refreshedGames: [GameItemModel] = [GameItemModel]()
    
    if let games = self.account_model.games {
        for game in games {
            
            var ps: [UserModel] = [UserModel]()
            
            for player in game.players {
                ps.append(UserModel(id: player.id, displayUsername: player.displayUsername))
            }
            
            refreshedGames.append(GameItemModel(players: ps, scores: game.scores, turn: game.turn))
        }
    }
    
    self.game_model!.games = refreshedGames
    
    var refreshedGameReqs: [GameReqItemModel] = [GameReqItemModel]()
    
    if let gameReqs = self.account_model.gameReq {
        for gameReq in gameReqs {
            
            var ps: [UserModel] = [UserModel]()
            
            for player in gameReq.players {
                ps.append(UserModel(id: player.id, displayUsername: player.displayUsername))
            }
            
            refreshedGameReqs.append(GameReqItemModel(players: ps, gameType: gameReq.gameType))
        }
    }
    
    self.game_model!.gameReqs = refreshedGameReqs
    
    self.gamesIsLoading = false
    
    // - - - - - Get Profile Pictures of players in games - - - - - //
    
    for i in 0..<self.game_model!.games.count {
        for j in 0..<self.game_model!.games[i].players.count {
            
            let id: String = self.game_model!.games[i].players[j].id
            
            if !self.memoized_users.contains(id) {
                
                self.profilePictureManager.getProfilePicture(id: id) { [unowned self] (image, error) in
                    self.memoized_users.insert(id)
                    self.game_model!.games[i].players[j].profilePicture = image
                }
            }
        }
    }
    
    for i in 0..<self.game_model!.gameReqs.count {
        for j in 0..<self.game_model!.gameReqs[i].players.count {
            
            let id: String = self.game_model!.gameReqs[i].players[j].id
            
            if !self.memoized_users.contains(id) {
                
                self.profilePictureManager.getProfilePicture(id: id) { [unowned self] (image, error) in
                    self.memoized_users.insert(id)
                    self.game_model!.gameReqs[i].players[j].profilePicture = image
                }
            }
        }
    }
}
 */
