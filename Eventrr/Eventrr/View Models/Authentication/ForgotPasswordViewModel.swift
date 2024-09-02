//
//  ForgotPasswordViewModel.swift
//  Eventrr
//
//  Created by Irtiza on 8/27/24.
//

import Foundation

/// The `ForgotPasswordViewModel` class manages the process of sending a password reset email to the user. 
/// It provides functionality to request a password reset and handles the status of the request.
/// > Important: Requires Firebase SDK to be installed and `GoogleService-Info.plist` file to be present in the project.
final class ForgotPasswordViewModel {
    
    static let identifier = String(describing: ForgotPasswordViewModel.self)
    
    // MARK: - Public Properties
 
    @Published public var sendPasswordResetEmailStatus: SendPasswordResetEmailStatus?
    public var userEmail: String?
    
    // MARK: - Public Methods
    
    /// Sends a password reset email to the user using the provided email address.
    /// Updates the `sendPasswordResetEmailStatus` property based on the success or failure of the request.
    public func sendPasswordResetEmail() {
        Task {
            do {
                guard let userEmail else {
                    sendPasswordResetEmailStatus = .failure(errorMessage: "Email is empty.")
                    return
                }
                
                try await FirebaseService.shared.sendPasswordResetEmail(email: userEmail)
                sendPasswordResetEmailStatus = .success(message: K.StringMessages.emailSentForPasswordReset)
            } catch {
                print("[\(ForgotPasswordViewModel.identifier)] - Error: \n\(error)")
                
                if let error = FirebaseService.shared.parseNetworkError(error as NSError) {
                    sendPasswordResetEmailStatus = .failure(errorMessage: error.message)
                } else {
                    sendPasswordResetEmailStatus = .failure(errorMessage: K.StringMessages.somethingWentWrong)
                }
            }
        }
    }
}

/// This enum represents the possible outcomes of a password reset email request.
enum SendPasswordResetEmailStatus {
    case success(message: String), failure(errorMessage: String)
}
