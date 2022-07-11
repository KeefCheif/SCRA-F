//
//  LoginManagerView.swift
//  SCRA-F
//
//  Created by KeefCheif on 6/15/22.
//

import SwiftUI

struct LoginManagerView: View {
    
    @StateObject var login_manager: LoginManagerViewModel
    
    @State private var email: String = ""
    @State private var password: String = ""
    
    var body: some View {
        
        if self.login_manager.loggedIn {
            MenuManagerView(menu_manager: MenuViewModel(), loggedIn: self.$login_manager.loggedIn)
        } else {
            
            VStack {
                
                Spacer()
                Spacer()
                
                TextField("Email", text: self.$email)
                    .textEntryFormat()
                
                SecureField("Password", text: self.$password)
                    .textEntryFormat()
                
        // - - - - - Forgot Password Button - - - - - //
                HStack {
                    Spacer()
                    Button(action: {
                        if !self.login_manager.isLoading {
                            self.login_manager.resetPasswordFormShowing = self.login_manager.registerFormShowing ? false : true
                        }
                    }, label: {
                        Text("Forgot Password?")
                    })
                }
                
                Spacer().frame(maxHeight: 50)
        
        // - - - - - Login Button - - - - - //
                Button(action: {
                    if !self.login_manager.isLoading {
                        self.login_manager.login(email: self.email, password: self.password)
                        self.password = ""
                    }
                }, label: {
                    Text("Login")
                        .textButtonFormat(color: UIColor.systemGreen.withAlphaComponent(0.9))
                })
                
        // - - - - - Register Button - - - - - //
                Button(action: {
                    if !self.login_manager.isLoading {
                        self.login_manager.registerFormShowing = self.login_manager.resetPasswordFormShowing ? false : true
                    }
                }, label: {
                    Text("Register")
                        .textButtonFormat(color: UIColor.systemBlue.withAlphaComponent(0.9))
                })
                
                if self.login_manager.isLoading {
                    GenericLoadingView().padding(10)
                }
                
                Spacer()
            }
            .padding(20)
            
            .sheet(isPresented: self.$login_manager.registerFormShowing) {
                RegisterForm(login_manager: self.login_manager)
            }
            .sheet(isPresented: self.$login_manager.resetPasswordFormShowing) {
                ResetPasswordForm(login_manager: self.login_manager)
            }
            
            .alert("Login Error", isPresented: .constant(self.login_manager.loginError != nil), actions: {
                Button("Okay", role: .cancel, action: { self.login_manager.loginError = nil })
            }, message: {
                if let loginError = self.login_manager.loginError {
                    Text(loginError.error.localizedDescription)
                }
            })
        }
    }
}

struct LoginManagerView_Previews: PreviewProvider {
    static var previews: some View {
        LoginManagerView(login_manager: LoginManagerViewModel())
    }
}

extension TextField {
    func textEntryFormat() -> some View {
        self.multilineTextAlignment(.center).font(.headline).padding(10).background(Rectangle().foregroundColor(Color(UIColor.gray.withAlphaComponent(0.25))))
    }
}

extension SecureField {
    func textEntryFormat() -> some View {
        self.multilineTextAlignment(.center).font(.headline).padding(10).background(Rectangle().foregroundColor(Color(UIColor.gray.withAlphaComponent(0.25))))
    }
}

extension Text {
    func textButtonFormat(color: UIColor) -> some View {
        self.font(.headline).foregroundColor(.white).frame(maxWidth: .infinity).padding(10).background(Rectangle().foregroundColor(Color(color)))
    }
}
