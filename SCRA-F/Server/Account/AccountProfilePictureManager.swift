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
        do {
            let compressed_image = try self.compressImage(image: image)
            
            let _ = profileStorage.putData(compressed_image) { (_, error) in
                
                if let _ = error {
                    completion(AccountError.uniqueError("Failed to upload profile picture."))
                }
            }
        } catch {
            completion(.imageTooLarge)
        }
    }
    
    public func deleteProfilePicture(completion: @escaping (AccountError?) -> Void) throws {
        
        guard Auth.auth().currentUser != nil else { throw AccountError.notLoggedIn }
        
        let profileStorage = self.storageRef.child("ProfilePictures/\(Auth.auth().currentUser!.uid)")
        
        // Delete the profile picture from Firebase Storage
        profileStorage.delete { (deleteError) in
            
            if let _ = deleteError {
                completion(AccountError.uniqueError("Failed to delete profile picture."))
            }
        }
    }
    
    public func changeProfilePicture(image: UIImage, completion: @escaping (AccountError?) -> Void) {
        
        do {
            try self.deleteProfilePicture() { (error) in
                if let error = error {
                    completion(error)
                } else {
                    self.uploadProfilePicture(image: image) { (uploadError) in
                        if let uploadError = uploadError {
                            completion(uploadError)
                        } else {
                            completion(nil)
                        }
                    }
                }
            }
        } catch {
            completion(AccountError.notLoggedIn)
        }
    }
    
    
    public func getProfilePictures(ids: [String], profilePics: [UIImage?], completion: @escaping ([UIImage?]?, AccountError?) -> Void) {
        
        if ids.isEmpty {
            completion(profilePics, nil)
            return
        }
        
        var new_ids: [String] = ids
        
        self.getProfilePicture(id: new_ids.removeLast()) { (image, error) in
            
            if let error = error {
                completion(nil, error)
            } else {
                
                self.getProfilePictures(ids: new_ids, profilePics: profilePics + [image]) { (images, innerError) in
                    
                    if let innerError = innerError {
                        completion(nil, innerError)
                    } else {
                        completion(images, nil)
                    }
                }
            }
        }
    }
    
    public func getProfilePicture(id: String?, completion: @escaping (UIImage?, AccountError?) -> Void) {
        
        guard Auth.auth().currentUser != nil else {
            completion(nil, .notLoggedIn)
            return
        }
        
        let userId = id == nil ? Auth.auth().currentUser!.uid : id!
        let path: String = "ProfilePictures/\(userId)"
        
        let imageRef = self.storageRef.child(path)
        // maxSize: 1 * 1024 * 1024
        imageRef.getData(maxSize: 1 * 1024 * 1024 * 1024) { (imageData, error) in
            if let imageData = imageData {
                completion(UIImage(data: imageData), nil)
            } else {
                completion(nil, nil)
            }
        }
        
    }
    
    private func compressImage(image: UIImage) throws -> Data {
       
        let pngImage = image.pngData()!
        
        if pngImage.count <= 1024 * 1024 {
            return pngImage
        } else {
            
            var compression: CGFloat = 0.5
            
            while compression >= 0 {
                
                let jpegImage = image.jpegData(compressionQuality: compression)!
                
                if jpegImage.count <= 1024 * 1024 {
                    return jpegImage
                }
                
                compression -= 0.25
            }
        }
        
        throw AccountError.imageTooLarge
    }
}
