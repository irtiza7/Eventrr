//
//  NameAndRoleViewModel.swift
//  Eventrr
//
//  Created by Dev on 8/5/24.
//

import UIKit
import FirebaseAuth

class NameAndRoleViewModel {
    
    init() {}
    
    // MARK: - Public Methods
    
    public func saveUserInformation(name: String, userType: String, view: UIViewController) {
        let loadingAlertVC = AlertService.shared.getLoadingAlertViewController()
        view.present(loadingAlertVC, animated: true)
        
        Task {
            do {
                guard let currentUser = Auth.auth().currentUser,
                      let email = currentUser.email else {return}
                
                let data: [String: String] = [
                    DBCollectionFields.Users.id.rawValue:  currentUser.uid,
                    DBCollectionFields.Users.email.rawValue: email,
                    DBCollectionFields.Users.name.rawValue: name,
                    DBCollectionFields.Users.type.rawValue: userType
                ]
                try await FirebaseService.shared.save(data: data, into: DBCollections.users.rawValue)
                
                DispatchQueue.main.async {
                    loadingAlertVC.dismiss(animated: true)
                }
            } catch {
                DispatchQueue.main.async {
                    loadingAlertVC.dismiss(animated: true)
                }
                await AlertService.shared.showFailureAlert(title: K.AuthConstants.errorTitle, message: error.localizedDescription, view: view)
            }
        }
    }
    
    public func validateForm(_ nameErrorLabel: UILabel, _ userTypeErrorLabel: UILabel) -> Bool {
        nameErrorLabel.isHidden && userTypeErrorLabel.isHidden
    }
}
