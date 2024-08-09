//
//  SignupViewModel.swift
//  Eventrr
//
//  Created by Dev on 8/5/24.
//

import UIKit
import FirebaseAuth

class SignupViewModel {
    
    // MARK: - Initializers
    
    init() {}
    
    // MARK: - Private Methods
    
    @MainActor
    private func showNameAndRoleViewController(parentView: UIViewController) {
        let storyboard = UIStoryboard(name: K.StoryboardIdentifiers.mainBundleStoryboard, bundle: nil)
        let nameAndRoleViewController = storyboard.instantiateViewController(withIdentifier: K.StoryboardIdentifiers.nameAndRoleViewController) as! NameAndRoleViewController
        parentView.navigationController?.pushViewController(nameAndRoleViewController, animated: true)
    }
    
    // MARK: - Public Methods
    
    public func signupUser(email: String, password: String, view: UIViewController) {
        let loadingAlertVC = AlertService.shared.getLoadingAlertViewController()
        view.present(loadingAlertVC, animated: true)
        
        Task {
            do {
                let _ = try await FirebaseService.shared.signup(email: email, password: password)
                
                DispatchQueue.main.async {
                    loadingAlertVC.dismiss(animated: true)
                }
                await showNameAndRoleViewController(parentView: view)
            } catch {
                DispatchQueue.main.async {
                    loadingAlertVC.dismiss(animated: true)
                }
                
                let nsError = error as NSError
                guard let parsedError = FirebaseService.shared.parseSignupError(nsError),
                      let signupError = SignupError(rawValue: parsedError.code) else {return}
                
                await AlertService.shared.showFailureAlert(title: K.AuthConstants.signupFailurePopupTitle, message: signupError.message, view: view)
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
    
    public func validatePassword(_ value: String) -> String? {
        if value.count == 0 {
            return K.AuthConstants.requiredFieldString
        } else if value.count < 8 {
            return K.AuthConstants.passwordLengthErrorString
        }
        return nil
    }
    
    public func validatePasswordAndConfirmPassword(_ password: String, _ confirmPassword: String) -> String? {
        if confirmPassword.count == 0 {
            return K.AuthConstants.requiredFieldString
        } else if password != confirmPassword {
            return K.AuthConstants.passwordsMismatchErrorString
        }
        return nil
    }
    
    public func validateForm(_ emailErrorField: UILabel, _ passwordErrorField: UILabel, _ confirmErrorPasswordField: UILabel) -> Bool {
        emailErrorField.isHidden && passwordErrorField.isHidden && confirmErrorPasswordField.isHidden
    }
}
