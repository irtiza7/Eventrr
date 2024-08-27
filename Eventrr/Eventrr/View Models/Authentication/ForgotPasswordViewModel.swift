//
//  ForgotPasswordViewModel.swift
//  Eventrr
//
//  Created by Irtiza on 8/27/24.
//

import Foundation

class ForgotPasswordViewModel {
    
    static let identifier = String(describing: ForgotPasswordViewModel.self)
    
    // MARK: - Public Properies
    
    @Published public var sendPasswordResetEmailStatus: SendPasswordResetEmailStatus?
    public var userEmail: String?
    
    // MARK: - Public Methods
    
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

enum SendPasswordResetEmailStatus {
    case success(message: String), failure(errorMessage: String)
}
