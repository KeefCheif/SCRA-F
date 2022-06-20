//
//  LoginViewModel.swift
//  SCRA-F
//
//  Created by KeefCheif on 6/15/22.
//

import Foundation
import FirebaseAuth

class LoginManagerViewModel: ObservableObject {
    
    @Published var loggedIn: Bool = Auth.auth().currentUser != nil
    
    @Published var registerFormShowing: Bool = false
    @Published var resetPasswordFormShowing: Bool = false
    
    @Published var loginError: AccountErrorType?
    
    @Published var isLoading: Bool = false
    
    private let accountManager: AccountOperations = AccountOperations()
    
    
    
    
    public func login(email: String, password: String) {
        
        guard !self.isLoading else { return }
        
        self.isLoading = true
        
        self.accountManager.signInEmail(email: email, password: password) { error in
            if let error = error {
                self.loginError = AccountErrorType(error: error)
                self.isLoading = false
            } else {
                self.isLoading = false
                self.loggedIn = Auth.auth().currentUser != nil
            }
        }
    }
    
    
    public func register(username: String, email: String, password: String, confirm_password: String) {
        
        guard !self.isLoading else { return }
        guard password == confirm_password else {
            self.loginError = AccountErrorType(error: .uniqueError("Passwords do not match."))
            return
        }
        
        self.isLoading = true
        
        self.accountManager.checkUsername(username: username) { username_error in
            if let username_error = username_error {
                
                self.loginError = AccountErrorType(error: username_error)
                self.isLoading = false
                
            } else {
                
                self.accountManager.createAccount(username: username, email: email, password: password) { error in
                    if let error = error {
                        self.loginError = AccountErrorType(error: error)
                    } else {
                        self.registerFormShowing = false
                        self.loggedIn = Auth.auth().currentUser != nil
                    }
                    
                    self.isLoading = false
                }
            }
        }
    }
    
    
    public func resetPassword(email: String) {
        
        guard !self.isLoading else { return }
        
        self.isLoading = true
        
        self.accountManager.resetPassword(email: email) { error in
            if let error = error {
                self.loginError = AccountErrorType(error: error)
                self.isLoading = false
            } else {
                self.isLoading = false
                self.resetPasswordFormShowing = false
            }
        }
    }
}
