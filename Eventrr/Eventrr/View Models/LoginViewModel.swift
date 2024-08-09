//
//  LoginViewModel.swift
//  Eventrr
//
//  Created by Dev on 8/5/24.
//

import UIKit
import FirebaseAuth

class LoginViewModel {
    
    // MARK: - Initializers
    
    init() {}
    
    // MARK: - Private Methods
    
    @MainActor
    private func showNameAndRoleViewController(parentView: UIViewController) {
        let storyboard = UIStoryboard(name: K.StoryboardIdentifiers.mainBundleStoryboard, bundle: nil)
        let nameAndRoleViewController = storyboard.instantiateViewController(withIdentifier: K.StoryboardIdentifiers.nameAndRoleViewController) as! NameAndRoleViewController
        
        parentView.navigationController?.pushViewController(nameAndRoleViewController, animated: true)
    }
    
    private func showNextViewController(parentView: UIViewController) async {
        guard let user = Auth.auth().currentUser else { return }
        let id = user.uid
        
        do {
            let querySnapshot = try await FirebaseService.shared.fetchAgainstId(id, from: DBCollections.users.rawValue)
            
            if let _ = querySnapshot.documents.first(where: { $0.data()["id"] as? String == id }) {
                // TODO: - NAVIGATE to EVENTS screen
            } else {
                await showNameAndRoleViewController(parentView: parentView)
            }
        } catch {
            await AlertService.shared.showFailureAlert(title: "Error", message: K.ErrorMessages.somethingWentWrong, view: parentView)
        }
    }
    
    // MARK: - Public Methods
    
    public func loginUser(email: String, password: String, parentView: UIViewController) {
        let loadingAlertVC = AlertService.shared.getLoadingAlertViewController()
        parentView.present(loadingAlertVC, animated: true)
        
        Task {
            do {
                let _ = try await FirebaseService.shared.login(email: email, password: password)
                
                DispatchQueue.main.async {
                    loadingAlertVC.dismiss(animated: true)
                }
                await showNextViewController(parentView: parentView)
            } catch {
                DispatchQueue.main.async {
                    loadingAlertVC.dismiss(animated: true)
                }
                
                let nsError = error as NSError
                guard let parsedError = FirebaseService.shared.parseLoginError(nsError),
                      let loginError = LoginError(rawValue: parsedError.code) else { return }
                
                await AlertService.shared.showFailureAlert(title: K.AuthConstants.loginFailurePopupTitle, message: loginError.message, view: parentView)
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
        if value.count == 0 { return K.AuthConstants.requiredFieldString }
        if value.count < 8 { return K.AuthConstants.passwordLengthErrorString }
        return nil
    }
    
    public func validateForm(_ emailErrorLabel: UILabel, _ passwordLabel: UILabel) -> Bool {
        emailErrorLabel.isHidden && passwordLabel.isHidden
    }
}
