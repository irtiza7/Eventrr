//
//  NameAndRoleViewModel.swift
//  Eventrr
//
//  Created by Dev on 8/5/24.
//

import UIKit
import FirebaseAuth

class NameAndRoleViewModel {
    
    // MARK: - Public Properties
    
    public let userRoles: [UserRole] = UserRole.allCases
    public var selectedUserRole: UserRole = UserRole.allCases.first!
    
    // MARK: - Public Methods
    
    public func saveUserInformation(name: String) async throws {
        guard let user = Auth.auth().currentUser,
              let email = user.email else {return}
        
        let data: [String: String] = [
            DBCollectionFields.Users.id.rawValue:  user.uid,
            DBCollectionFields.Users.email.rawValue: email,
            DBCollectionFields.Users.name.rawValue: name,
            DBCollectionFields.Users.type.rawValue: selectedUserRole.rawValue
        ]
        
        try await FirebaseService.shared.saveUser(data: data, into: DBCollections.Users.rawValue)
        UserService.createInstance(name: name, role: selectedUserRole.rawValue)
    }
    
    public func validateForm(_ nameErrorLabel: UILabel, _ userTypeErrorLabel: UILabel) -> Bool {
        nameErrorLabel.isHidden && userTypeErrorLabel.isHidden
    }
}
