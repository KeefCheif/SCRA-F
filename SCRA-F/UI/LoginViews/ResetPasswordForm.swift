//
//  ResetPasswordForm.swift
//  SCRA-F
//
//  Created by peter allgeier on 6/20/22.
//

import SwiftUI

struct ResetPasswordForm: View {
    
    @ObservedObject var login_manager: LoginManagerViewModel
    
    @State private var email: String = ""
    
    var body: some View {
        
        VStack(spacing: 15) {
            TextField("Email", text: self.$email)
                .textEntryFormat()
            
            Spacer().frame(maxHeight: 20)
            
            Button(action: {
                if !self.login_manager.isLoading {
                    self.login_manager.resetPassword(email: self.email)
                }
            }, label: {
                Text("Send Recovery Email")
                    .textButtonFormat(color: UIColor.systemGreen.withAlphaComponent(0.9))
            })
            
            Button(action: {
                if !self.login_manager.isLoading {
                    self.login_manager.resetPasswordFormShowing = false
                }
            }, label: {
                Text("Cancel")
                    .textButtonFormat(color: UIColor.systemRed.withAlphaComponent(0.9))
            })
        }
        .padding(20)
        .alert("Recovery Failed", isPresented: .constant(self.login_manager.loginError != nil), actions: {
            Button("Okay", role: .cancel, action: {
                self.login_manager.loginError = nil
            })
        }, message: {
            if let loginError = self.login_manager.loginError {
                Text(loginError.error.localizedDescription)
            }
        })
    }
}

struct ResetPasswordForm_Previews: PreviewProvider {
    static var previews: some View {
        ResetPasswordForm(login_manager: LoginManagerViewModel())
    }
}
