//
//  ForgotPasswordViewController.swift
//  Eventrr
//
//  Created by Dev on 8/3/24.
//

import UIKit

class ForgotPasswordViewController: UIViewController {
    
    static let identifier = String(describing: ForgotPasswordViewController.self)
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var emailErrorLabel: UILabel!
    @IBOutlet weak var sendResetLinkButton: UIButton!
    
    // MARK: - Public Properties
    
    public var userEmail: String?
    
    // MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUserInterface()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
    }
    
    // MARK: - IBActions
    
    @IBAction func sendResetLinkButtonPressed(_ sender: UIButton) {
        guard let email = emailField.text else {return}
        
        if let errorMessage = Utility.validateEmail(email) {
            emailErrorLabel.text = errorMessage
            emailErrorLabel.isHidden = false
        }
        
        emailErrorLabel.isHidden = true
        sendPasswordResetEmail(email: email)
    }
    
    // MARK: - Private Methods
    
    private func sendPasswordResetEmail(email: String) {
        let spinner = Popups.loadingPopup()
        present(spinner, animated: true)
        
        Task {
            do {
                try await FirebaseService.shared.sendPasswordResetEmail(email: email)
                spinner.dismiss(animated: true)
                Popups.displaySuccess(message: K.StringMessages.emailSentForPasswordReset) { [weak self] popup in
                    self?.present(popup, animated: true)
                }
            } catch {
                spinner.dismiss(animated: true)
                
                print("[\(ForgotPasswordViewController.identifier)] - Error: \n\(error)")
                Popups.displayFailure(message: K.StringMessages.somethingWentWrong) { [weak self] popup in
                    self?.present(popup, animated: true)
                }
            }
        }
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func setupUserInterface() {
        navigationController?.isNavigationBarHidden = false
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        emailField.text = userEmail ?? ""
        emailErrorLabel.isHidden = true
        
        sendResetLinkButton.layer.cornerRadius = K.UI.defaultPrimaryCornerRadius
    }
}
