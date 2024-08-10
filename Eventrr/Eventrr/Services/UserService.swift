//
//  UserService.swift
//  Eventrr
//
//  Created by Dev on 8/12/24.
//

import Foundation
import FirebaseAuth

final class UserService {
    
    // MARK: - Static Properties
    
    static var shared: UserService?
    
    // MARK: - Static Methods
    
    static func createInstance(name: String, role: String) {
        if UserService.shared == nil {
            guard let email = Auth.auth().currentUser?.email,
                  let id = Auth.auth().currentUser?.uid,
                  let role = UserRole(rawValue: role) else { return }
            
            let user = UserModel(id: id, email: email, name: name, role: role)
            UserService.shared = UserService(user)
        }
    }
    
    // MARK: - Private Properties
    
    public private(set) var user: UserModel
    
    // MARK: - Initiliazers
    
    private init(_ user: UserModel) {
        self.user = user
    }
}
