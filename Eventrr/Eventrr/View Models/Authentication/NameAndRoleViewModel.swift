//
//  NameAndRoleViewModel.swift
//  Eventrr
//
//  Created by Dev on 8/5/24.
//

import UIKit
import FirebaseAuth

/// The `NameAndRoleViewModel` class manages user information related to their name and role in the application.
/// It handles saving user data to Firebase and validating form input.
/// > Important: Requires Firebase SDK to be installed and GoogleService-Infor.plist file to be present in the project.
final class NameAndRoleViewModel {
    
    // MARK: - Public Properties
    
    /// An array of all possible user roles available for selection.
    public let userRoles: [UserRole] = UserRole.allCases
    
    /// The currently selected user role. Defaults to the first role in the `UserRoles` array.
    public var selectedUserRole: UserRole = UserRole.allCases.first!
    
    // MARK: - Public Methods
    
    /// Saves the user's information to Firebase, including their name and selected role.
    ///
    /// Gets additional user information such as email, role, id, etc. from the current user object in FirebaseAuthentical's `Auth.auth`
    /// - Parameters:
    ///   - name: The name of the user to be saved.
    /// - Throws: An error if the operation fails.
    public func saveUserInformation(name: String) async throws {
        guard let user = Auth.auth().currentUser, let email = user.email else { return }
        
        let data = [
            DatabaseTableColumns.Users.authId.rawValue: user.uid,
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
    
    /// Validates the form by checking if the name and user type error labels are hidden.
    /// - Parameters:
    ///   - nameErrorLabel: The label displaying the error message for the name field.
    ///   - userTypeErrorLabel: The label displaying the error message for the user role field.
    /// - Returns: A boolean indicating whether the form is valid (both error labels are hidden).
    public func validateForm(_ nameErrorLabel: UILabel, _ userTypeErrorLabel: UILabel) -> Bool {
        nameErrorLabel.isHidden && userTypeErrorLabel.isHidden
    }
}
