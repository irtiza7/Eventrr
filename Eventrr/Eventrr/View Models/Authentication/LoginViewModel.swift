//
//  LoginViewModel.swift
//  Eventrr
//
//  Created by Dev on 8/5/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class LoginViewModel {
    
    // MARK: - Private Methods
    
    private func initializeUserService(document: QueryDocumentSnapshot) {
        let data = document.data()
        let name = data[DBCollectionFields.Users.name.rawValue] as! String
        let role = data[DBCollectionFields.Users.type.rawValue] as! String
        
        UserService.createInstance(name: name, role: role)
    }
    
    // MARK: - Public Methods
    
    public func checkUserLoggedInStatus() async -> Bool {
        /*
         Firebase sets currentUser property to nil if user is dileberaty
         or automatically logged out
         Non nil value means user is logged in
         */
        guard let user = Auth.auth().currentUser else {return false}
        let userId = user.uid
        
        do {
            let querySnapshot = try await FirebaseService.shared.fetchDataAgainstId(userId, from: DBCollections.Users.rawValue)
            let document = querySnapshot.documents.first(where: {
                let data = $0.data()
                return (data[DBCollectionFields.Users.id.rawValue] as? String) == userId
            })
            if let document {
                initializeUserService(document: document)
            }
        } catch {
            print("[\(String(describing: LoginViewModel.self))] - Error: \n\(error)")
        }
        return true
    }
    
    public func loginUser(email: String, password: String) async throws -> AuthDataResult {
        return try await FirebaseService.shared.login(email: email, password: password)
    }
    
    public func validateUserRequiredInformation() async throws -> Bool {
        guard let user = Auth.auth().currentUser else {return false}
        let userId = user.uid
        
        let querySnapshot = try await FirebaseService.shared.fetchDataAgainstId(
            userId,
            from: DBCollections.Users.rawValue
        )
        let document = querySnapshot.documents.first(where: {
            let data = $0.data()
            return (data[DBCollectionFields.Users.id.rawValue] as? String) == userId
        })
        
        /* Invalidate if no record of user's information exists */
        guard let document else {return false}
        
        initializeUserService(document: document)
        return true
    }
    
    public func validateForm(_ emailErrorLabel: UILabel, _ passwordLabel: UILabel) -> Bool {
        emailErrorLabel.isHidden && passwordLabel.isHidden
    }
}
