//
//  ForgotViewModel.swift
//  Eventrr
//
//  Created by Dev on 8/5/24.
//

import UIKit
import FirebaseAuth

class ForgotPasswordViewModel {
    
    // MARK: - Initializers
    
    init() {}
    
    // MARK: - Public Methods
    
    public func sendPasswordResetEmail(email: String, view: UIViewController) {
        
        // TODO: - Convert callback based login to async/await logic
        
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            guard error == nil else {
                Task {
                    await AlertService.shared.showFailureAlert(title: K.AuthConstants.errorTitle, message: K.ErrorMessages.somethingWentWrong, view: view)
                }
                return
            }
            AlertService.shared.showSuccessAlert(message: K.AuthConstants.emailSentSuccessString) { [weak view] (alertVC) in
                view?.present(alertVC, animated: true)
            }
        }
    }
    
    public func validateEmail(_ value: String) -> String? {
        if value.count == 0 { return K.AuthConstants.requiredFieldString }
        
        let predicate = NSPredicate(format:"SELF MATCHES %@", K.AuthConstants.emailRegex)
        if !(predicate.evaluate(with: value)) {
            return K.AuthConstants.enterValidEmailErrorString
        }
        return nil
    }
}
