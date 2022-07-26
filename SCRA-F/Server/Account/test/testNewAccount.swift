//
//  testNewAccount.swift
//  SCRA-F
//
//  Created by peter allgeier on 7/14/22.
//

import Foundation
import Firebase
import FirebaseAuth


class TestNewAccount: ObservableObject {
    
    init() {
        
        let db = Firestore.firestore()
        
        let userDoc = db.collection("users").document(Auth.auth().currentUser!.uid)
        
        userDoc.getDocument { (docSnap, error) in
            
            if let _ = error {
                print("ERROR OPENING MAIN DOCUMENT")
            } else if let docSnap = docSnap {
                
                let data = docSnap.data()!
                
                do {
                    
                    let jsonAccount = try JSONSerialization.data(withJSONObject: data)
                    let accountModel = try JSONDecoder().decode(NewAccountModel.self, from: jsonAccount)
                    
                    userDoc.collection("social").getDocuments { (querySnap, qError) in
                        
                        if let _ = qError {
                            print("ERROR OPENING SOCIAL DOCUMENTS")
                        } else if let querySnap = querySnap {
                            
                            let docs = querySnap.documents
                            
                            guard docs.count == 2 else {
                                print("NOT THE RIGHT NUMBER OF SOCIAL DOCUMENTS")
                                return
                            }
                            
                            let data1 = docs[0].data()
                            let data2 = docs[1].data()
                            
                            print(data1)
                            
                        } else {
                            print("BOTH NIL IN SOCIAL DOCUMENTS")
                        }
                    }
                    
                } catch {
                    print("ERROR DECODING DATA FROM FIRST DOCUMENT")
                }
                
            } else {
                print("BOTH NIL IN FIRST DOCUMENT")
            }
        }
        
    }
    
}

struct NewAccountModel: Codable {
    
    var username: String
    var displayUsername: String
    var id: String
}
