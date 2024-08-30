//
//  SignupViewModel.swift
//  Eventrr
//
//  Created by Dev on 8/5/24.
//

import UIKit
import FirebaseAuth

/// The `SignupViewModel` class manages the user signup process, handling the creation of new user accounts and validating form input.
/// It uses `@Published` properties to communicate the status of the signup process, allowing the UI to respond to changes.
/// > Important: Requires Firebase SDK to be installed and GoogleService-Infor.plist file to be present in the project.
final class SignupViewModel {
    
    /// A string identifier for the `SignupViewModel` class, used for logging.
    static let identifier = String(describing: SignupViewModel.self)
    
    // MARK: - Public Properties
    
    /// A published property that holds the status of the signup process.
    @Published public var signupStatus: SignupStatus?
    
    // MARK: - Public Methods
    
    /// Signs up a new user with the provided email and password.
    /// Updates the `signupStatus` property based on the success or failure of the signup attempt.
    /// - Parameters:
    ///   - email: The email address of the user.
    ///   - password: The password of the user.
    public func signupUser(email: String, password: String) {
        Task {
            do {
                let _ = try await FirebaseService.shared.signup(email: email, password: password)
                signupStatus = .success
            } catch {
                print("[\(SignupViewModel.identifier)] - Error: \n\(error)")
                
                guard let parsedError = FirebaseService.shared.parseSignupError(error as NSError) else { return }
                signupStatus = .failure(errorMessage: parsedError.message)
            }
        }
    }
    
    /// Validates the signup form by checking if the email, password, and confirm password error labels are hidden.
    /// - Parameters:
    ///   - emailErrorField: The label displaying the email error message.
    ///   - passwordErrorField: The label displaying the password error message.
    ///   - confirmErrorPasswordField: The label displaying the confirm password error message.
    /// - Returns: A boolean indicating whether the form is valid (all error labels are hidden).
    public func validateForm(_ emailErrorField: UILabel, _ passwordErrorField: UILabel, _ confirmErrorPasswordField: UILabel) -> Bool {
        emailErrorField.isHidden && passwordErrorField.isHidden && confirmErrorPasswordField.isHidden
    }
}

/// Enum representing the status of the signup process.
enum SignupStatus {
    case success
    case failure(errorMessage: String)
}

