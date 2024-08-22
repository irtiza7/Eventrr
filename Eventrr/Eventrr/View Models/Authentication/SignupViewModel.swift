//
//  SignupViewModel.swift
//  Eventrr
//
//  Created by Dev on 8/5/24.
//

import UIKit
import FirebaseAuth

class SignupViewModel {
    
    static let identifier = String(describing: SignupViewModel.self)
    
    // MARK: - Public Properties
    
    @Published public var signupStatus: SignupStatus?
    
    // MARK: - Public Methods
    
    public func signupUser(email: String, password: String) {
        Task {
            do {
                let _ = try await FirebaseService.shared.signup(email: email, password: password)
                signupStatus = .success
            } catch {
                print("[\(SignupViewModel.identifier)] - Error: \n\(error)")
                
                guard let parsedError = FirebaseService.shared.parseSignupError(error as NSError) else {return}
                signupStatus = .failure(errorMessage: parsedError.message)
                
            }
        }
    }
    
    public func validateForm(_ emailErrorField: UILabel, _ passwordErrorField: UILabel, _ confirmErrorPasswordField: UILabel) -> Bool {
        emailErrorField.isHidden && passwordErrorField.isHidden && confirmErrorPasswordField.isHidden
    }
}

enum SignupStatus {
    case success, failure(errorMessage: String)
}
