//
//  SignupViewController.swift
//  Eventrr
//
//  Created by Dev on 8/2/24.
//

import UIKit
import Combine

class SignupViewController: UIViewController {
    
    static let identifier = String(describing: SignupViewController.self)
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var emailErrorLabel: UILabel!
    
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var passwordErrorLabel: UILabel!
    
    @IBOutlet weak var confirmPasswordField: UITextField!
    @IBOutlet weak var confirmPasswordErrorLabel: UILabel!
    
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    
    // MARK: - Private Properties
    
    private let viewModel = SignupViewModel()
    private let spinner = Popups.loadingPopup()
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUserInterface()
        setupSubscriptions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
    }
    
    // MARK: - IBActions
    
    @IBAction func signupButtonPressed(_ sender: UIButton) {
        guard let email = emailField.text,
              let password = passwordField.text,
              let confirmPassword = confirmPasswordField.text else {return}
        
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        confirmPasswordField.resignFirstResponder()
        
        if let errorMessage = ValidationUtility.validateEmail(email) {
            emailErrorLabel.text = errorMessage
            emailErrorLabel.isHidden = false
        } else {
            emailErrorLabel.isHidden = true
        }
        
        if let errorMessage = ValidationUtility.validatePassword(password) {
            passwordErrorLabel.text = errorMessage
            passwordErrorLabel.isHidden = false
        } else {
            passwordErrorLabel.isHidden = true
        }
        
        if let errorMessage = ValidationUtility.validatePasswordAndConfirmPassword(password, confirmPassword) {
            confirmPasswordErrorLabel.text = errorMessage
            confirmPasswordErrorLabel.isHidden = false
        } else {
            confirmPasswordErrorLabel.isHidden = true
        }
        
        if viewModel.validateForm(emailErrorLabel, passwordErrorLabel, confirmPasswordErrorLabel) {
            present(spinner, animated: true)
            viewModel.signupUser(email: email, password: password)
        }
    }
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Private Methods
    
    private func setupSubscriptions() {
        viewModel.$signupStatus
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (status: SignupStatus?) in
                guard let status, let self else {return}
                self.spinner.dismiss(animated: true)
                
                switch status {
                case .success:
                    let storyboard = UIStoryboard(name: K.MainStoryboardIdentifiers.mainBundle, bundle: nil)
                    let viewController = storyboard.instantiateViewController(withIdentifier: NameAndRoleViewController.identifier)
                    navigationController?.pushViewController(viewController, animated: true)
                    
                case .failure(let errorMessage):
                    Popups.displayFailure(
                        title: K.StringMessages.signupFailurePopupTitle,
                        message: errorMessage
                    ) {
                        [weak self] popup in
                        self?.present(popup, animated: true)
                    }
                }
                
            }.store(in: &cancellables)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func setupUserInterface() {
        navigationController?.isNavigationBarHidden = false
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        emailErrorLabel.isHidden = true
        passwordErrorLabel.isHidden = true
        confirmPasswordErrorLabel.isHidden = true
        
        signupButton.layer.cornerRadius = K.UI.defaultPrimaryCornerRadius
        loginButton.layer.cornerRadius = K.UI.defaultSecondardCornerRadius
    }
}
