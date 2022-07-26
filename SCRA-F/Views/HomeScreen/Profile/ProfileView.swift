//
//  ProfileView.swift
//  SCRA-F
//
//  Created by KeefCheif on 6/23/22.
//

import SwiftUI

struct ProfileView: View {
    
    @ObservedObject var menu_manager: MenuViewModel
    
    @State var showPickerAlert: Bool = false
    @State var showImagePicker: Bool = false
    @State var newProfilePicture: UIImage?
    
    var body: some View {
        
        VStack {
            
            HStack {
                
                VStack {
                    
                    Button(action: {
                        self.showPickerAlert = true
                    }, label: {
                        if let profile_picture = self.menu_manager.account_model!.profile_picture{
                            Image(uiImage: profile_picture)
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: 50)
                                .clipShape(Circle())
                        } else {
                            Image(systemName: "person.circle")
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: 50)
                                .clipShape(Circle())
                        }
                    })
                    
                    Text(self.menu_manager.account_model!.displayUsername)
                }
                
                Spacer()
            }
            
            Spacer()
        }
        .padding(20)
        .alert("Modify Profile", isPresented: self.$showPickerAlert, actions: {
            
            Button("Yes", role: .cancel, action: {
                self.showPickerAlert = false
                self.showImagePicker = true
            })
            
            Button("No", role: .destructive, action: {
                self.showPickerAlert = false
            })
            
        }, message: {
            Text("Would you like to change your profile picture?")
        })
        
        .sheet(isPresented: self.$showImagePicker, onDismiss: { self.menu_manager.changeProfilePicture(picture: self.newProfilePicture) }) {
            ImagePicker(image: self.$newProfilePicture, showImagePicker: self.$showImagePicker, sourceType: .photoLibrary)
        }
    }
}

/*
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
*/
