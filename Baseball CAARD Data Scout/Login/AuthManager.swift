//
//  AuthManager.swift
//  Baseball CAARD Data Scout
//
//  Created by Benjamin Hilger on 8/7/21.
//

import Foundation
import Firebase

class AuthManager {
    
    private static let manager = AuthManager()
    
    private var user: User?
    
    static func getShared() -> AuthManager {
        return manager
    }
    
    func getUser() -> User? {
        return user
    }
    
    func loginUser(email: String, password: String, completion: @escaping (Bool) -> Void) {
        guard email != "", password != "" else {
            return
        }
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                print(error)
                completion(false)
            } else if result != nil {
                self.user = result?.user
                completion(true)
            }
        }
    }
    
    func logoutUser() {
        do {
            try Auth.auth().signOut()
            user = nil
        } catch {
            
        }
    }
    
}

