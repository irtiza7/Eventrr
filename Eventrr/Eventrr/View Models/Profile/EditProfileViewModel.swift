//
//  EditProfileViewModel.swift
//  Eventrr
//
//  Created by Dev on 8/21/24.
//

import Foundation
import FirebaseAuth

class EditProfileViewModel: ObservableObject {
    
    @Published var modifiedName: String = ""
    @Published var user: UserModel?
    
    public var userRolesList: [UserRole] = []
    public var selectedRole: UserRole = .Admin
    
    init() {
        if UserRole.allCases.count != 0 {
            userRolesList = UserRole.allCases
        }
        
        guard let currentUser = UserService.shared?.user,
              let name = currentUser.name, let role = currentUser.role else {return}
        
        user = currentUser
        modifiedName = name
        selectedRole = role
    }
    
    // MARK: - Public Methods
    
    public func updateProfile() async -> String? {
        guard let currentUser = user, let id = currentUser.id else { return K.StringMessages.somethingWentWrong }
        guard modifiedName != "" else { return "Name can't be empty." }
        
        var isInformationModified = false
        var data: [String: String] = [:]
        
        if selectedRole.rawValue != currentUser.role!.rawValue {
            data[DatabaseTableColumns.Users.type.rawValue] = selectedRole.rawValue
            isInformationModified = true
        }
        
        if modifiedName != currentUser.name! {
            data[DatabaseTableColumns.Users.name.rawValue] = modifiedName
            isInformationModified = true
        }
        
        if !isInformationModified {
            return "You haven't changed anything."
        }
        
        do {
            try await FirebaseService.shared.update(
                data: data,
                recordId: id,
                table: DatabaseTables.Users.rawValue
            )
            
            try await FirebaseService.shared.updateOwnerNameInEvents(ownerId: id, newName: modifiedName)
            
            try Auth.auth().signOut()
            
            Task { @MainActor  in
                RealmService.shared?.deleteAllObjects(ofType: UserRealmModel.self)
            }
        } catch {
            print("[\(String(describing: EditProfileView.self))] - Error: \n\(error)")
            return "Counld't update profile, try later."
        }
        return nil
    }
}
