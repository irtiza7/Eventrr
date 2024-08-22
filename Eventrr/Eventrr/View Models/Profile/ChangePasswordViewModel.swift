//
//  ChangePasswordViewModel.swift
//  Eventrr
//
//  Created by Dev on 8/22/24.
//

import Foundation
import FirebaseAuth

class ChangePasswordViewModel: ObservableObject {
    
    @Published var userEmail: String = ""
    @Published var currentPassword: String = ""
    @Published var newPassword: String = ""
    @Published var confirmPassword: String = ""
    
    public var user: UserModel?
    
    init() {
        guard let user = UserService.shared?.user else {return}
        self.user = user
        userEmail = user.email
    }
    
    public func reauthenticateUser() async throws -> String? {
        let credential: AuthCredential = EmailAuthProvider.credential(
            withEmail: userEmail,
            password: currentPassword
        )
        
        do {
            try await FirebaseService.shared.reauthenticateUser(credential: credential)
            return nil
            
        } catch let error as AuthError {
            UserService.shared = nil
            throw error
            
        } catch {
            print("[\(String(describing: ChangePasswordViewModel.self))] - Error: \n\(error)")
            return "Couldn't verify your current credentials, try later."
        }
    }
    
    public func updatePassword() async throws -> String? {
        do {
            try await FirebaseService.shared.updatePassword(password: newPassword)
            
            UserService.shared = nil
            try Auth.auth().signOut()
            
            return nil
        } catch let error as AuthError {
            UserService.shared = nil
            throw error
        } catch {
            print("[\(String(describing: ChangePasswordViewModel.self))] - Error: \n\(error)")
            return "Something went wrong, try later."
        }
    }
    
    public func validateFields() throws -> String? {
        guard userEmail != "", currentPassword != "", newPassword != "", confirmPassword != "" else {
            return "Required fields are empty."
        }
        
        guard let user else { throw AuthError.userNotAuthenticated }
        
        if let errorMessage = ValidationUtility.validateEmail(userEmail) { return errorMessage }
        if userEmail != user.email { return "Entered email doesn't match with account email." }
        
        if let _ = ValidationUtility.validatePassword(currentPassword) { return "Enter a valid current password." }
        if let _ = ValidationUtility.validatePassword(newPassword) { return "Enter a valid new password." }
        if let _ = ValidationUtility.validatePassword(confirmPassword) { return "Enter a valid confirm password." }
        if currentPassword == newPassword { return "New password is same as old password." }
        
        if let errorMessage = ValidationUtility.validatePasswordAndConfirmPassword(
            newPassword,
            confirmPassword
        ) { return errorMessage }
        
        return nil
    }
}
