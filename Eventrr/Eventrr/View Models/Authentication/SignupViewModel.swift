//
//  SignupViewModel.swift
//  Eventrr
//
//  Created by Dev on 8/5/24.
//

import UIKit
import FirebaseAuth

class SignupViewModel {
    
    // MARK: - Public Methods
    
    public func signupUser(email: String, password: String) async throws -> AuthDataResult {
        return try await FirebaseService.shared.signup(email: email, password: password)
    }
    
    public func validateForm(_ emailErrorField: UILabel, _ passwordErrorField: UILabel, _ confirmErrorPasswordField: UILabel) -> Bool {
        emailErrorField.isHidden && passwordErrorField.isHidden && confirmErrorPasswordField.isHidden
    }
}
