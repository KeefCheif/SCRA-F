//
//  AccountProfilePictureManager.swift
//  SCRA-F
//
//  Created by KeefCheif on 5/19/22.
//

import Firebase
import FirebaseAuth
import FirebaseStorage
import SwiftUI

struct AccountProfilePictureManager {
    
    let db = Firestore.firestore()
    let storageRef = Storage.storage().reference()
    
    public func uploadProfilePicture(image: UIImage, completion: @escaping (AccountError?) -> Void) {
        
        guard Auth.auth().currentUser != nil else {
            completion(AccountError.notLoggedIn)
            return
        }
        
        let profileStorage = self.storageRef.child("ProfilePictures/\(Auth.auth().currentUser!.uid)")
        
        // Compress the image and upload it to Firebase Storage
        let _ = profileStorage.putData(self.compressImage(image: image, 0.9)) { (_, error) in
            
            if let _ = error {
                completion(AccountError.uniqueError("Failed to upload profile picture."))
            } else {
        // Get the url for the image and upload it to the user's account in the Firestore DB
                
                let userDoc = self.db.collection("users").document(Auth.auth().currentUser!.uid)
                userDoc.updateData(["hasProfilePicture": true]) { (_) in
                    completion(nil)
                }
                /*
                profileStorage.downloadURL { (url, error) in
                    
                    if let _ = error {
                        completion(AccountError.uniqueError("Failed to get image url."))
                    } else if let url = url {
                        
                        let userDoc = db.collection("users").document(Auth.auth().currentUser!.uid)
                        
                        userDoc.setData(["profilePicture": url.absoluteString], merge: true)
                        userDoc.updateData(["hasProfilePicture": true]) { (_) in
                            completion(nil)
                        }
                        
                    } else {
                        completion(AccountError.uniqueError("Failed to get image url."))
                    }
                }
                 */
            }
        }
    }
    
    public func deleteProfilePicture(completion: @escaping (AccountError?) -> Void) throws {
        
        guard Auth.auth().currentUser != nil else { throw AccountError.notLoggedIn }
        
        let profileStorage = self.storageRef.child("ProfilePictures/\(Auth.auth().currentUser!.uid)")
        
        // Delete the profile picture from Firebase Storage
        profileStorage.delete { (deleteError) in
            
            if let _ = deleteError {
                completion(AccountError.uniqueError("Failed to delete profile picture."))
            } else {
                
        // Delete & update the profile picture info for the user's account in Firestore
                let userDoc = db.collection("users").document(Auth.auth().currentUser!.uid)
                
                userDoc.updateData([
                    "profilePicture": FieldValue.delete(),
                    "hasProfilePicture": false
                ]) { (_) in
                    completion(nil)
                }
            }
        }
    }
    
    public func changeProfilePicture(image: UIImage, completion: @escaping (AccountError?) -> Void) {
        
        do {
            try self.deleteProfilePicture() { (error) in
                if let error = error {
                    completion(error)
                } else {
                    do {
                        try self.uploadProfilePicture(image: image) { (uploadError) in
                            if let uploadError = uploadError {
                                completion(uploadError)
                            } else {
                                completion(nil)
                            }
                        }
                    } catch {
                        completion(AccountError.notLoggedIn)
                    }
                }
            }
        } catch {
            completion(AccountError.notLoggedIn)
        }
    }
    
    public func getProfilePicture(completion: @escaping (UIImage?, AccountError?) -> Void) {
        
        guard Auth.auth().currentUser != nil else {
            completion(nil, AccountError.notLoggedIn)
            return
        }
        
        let imageRef = self.storageRef.child("ProfilePictures/\(Auth.auth().currentUser!.uid)")
        
        imageRef.getData(maxSize: 1 * 1024 * 1024) { (imageData, error) in
            if let _ = error {
                completion(nil, AccountError.uniqueError("Failed to download profile picture."))
            } else if let imageData = imageData {
                completion(UIImage(data: imageData), nil)
            } else {
                completion(nil, AccountError.uniqueError("Failed to download profile picture."))
            }
        }
    }
    
    private func compressImage(image: UIImage, _ compression: CGFloat) -> Data {
        return image.jpegData(compressionQuality: compression)!
    }
}
