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
        guard let user = Auth.auth().currentUser, let email = user.email else {return}
        
        let data = [
            DatabaseTableColumns.Users.authId.rawValue:  user.uid,
            DatabaseTableColumns.Users.email.rawValue: email,
            DatabaseTableColumns.Users.name.rawValue: name,
            DatabaseTableColumns.Users.type.rawValue: selectedUserRole.rawValue
        ]
        let id = try await FirebaseService.shared.create(data: data, table: DatabaseTables.Users.rawValue)
        
        let userModel = UserModel(
            id: id,
            authId: user.uid,
            email: email,
            name: name,
            role: selectedUserRole
        )
        UserService.createInstance(userModel: userModel)
    }
    
    public func validateForm(_ nameErrorLabel: UILabel, _ userTypeErrorLabel: UILabel) -> Bool {
        nameErrorLabel.isHidden && userTypeErrorLabel.isHidden
    }
}
