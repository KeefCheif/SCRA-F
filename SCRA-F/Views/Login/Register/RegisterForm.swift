//
//  RegisterForm.swift
//  SCRA-F
//
//  Created by KeefCheif on 6/20/22.
//

import SwiftUI

struct RegisterForm: View {
    
    @ObservedObject var login_manager: LoginManagerViewModel
    
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirm_password: String = ""
    
    var body: some View {
        
        VStack(spacing: 15) {
            
            TextField("Username", text: self.$username)
                .textEntryFormat()
            
            TextField("Email", text: self.$email)
                .textEntryFormat()
            
            SecureField("Password", text: self.$password)
                .textEntryFormat()
            
            SecureField("Confirm Password", text: self.$confirm_password)
                .textEntryFormat()
            
            Spacer().frame(maxHeight: 10)
            
    // - - - - - Submit Button - - - - - //
            Button(action: {
                if !self.login_manager.isLoading {
                    self.login_manager.register(username: self.username, email: self.email, password: self.password, confirm_password: self.confirm_password)
                }
            }, label: {
                Text("Submit")
                    .textButtonFormat(color: UIColor.systemGreen.withAlphaComponent(0.9))
            })
            
    // - - - - - Cancel Button - - - - - //
            Button(action: {
                if !self.login_manager.isLoading {
                    self.login_manager.registerFormShowing = false
                }
            }, label: {
                Text("Cancel")
                    .textButtonFormat(color: UIColor.systemRed.withAlphaComponent(0.9))
            })
            
            if self.login_manager.isLoading {
                GenericLoadingView().padding(10)
            }
        }
        .padding(20)
        
        .alert("Registration Failed", isPresented: .constant(self.login_manager.loginError != nil), actions: {
            Button("Okay", role: .cancel, action: {
                self.login_manager.loginError = nil
                self.password = ""
                self.confirm_password = ""
            })
        }, message: {
            if let loginError = self.login_manager.loginError {
                Text(loginError.error.localizedDescription)
            }
        })
    }
}

struct RegisterForm_Previews: PreviewProvider {
    static var previews: some View {
        RegisterForm(login_manager: LoginManagerViewModel())
    }
}
