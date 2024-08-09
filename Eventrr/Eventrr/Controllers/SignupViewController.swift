//
//  SignupViewController.swift
//  Eventrr
//
//  Created by Dev on 8/2/24.
//

import UIKit
import FirebaseAuth

class SignupViewController: UIViewController {
    
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
    
    // MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUserInterface()
    }
    
    // MARK: - IBActions
    
    @IBAction func signupButtonPressed(_ sender: UIButton) {
        guard let email = emailField.text,
              let password = passwordField.text,
              let confirmPassword = confirmPasswordField.text else {return}
        
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        confirmPasswordField.resignFirstResponder()
        
        if let errorMessage = viewModel.validateEmail(email) {
            emailErrorLabel.text = errorMessage
            emailErrorLabel.isHidden = false
        } else {
            emailErrorLabel.isHidden = true
        }
        
        if let errorMessage = viewModel.validatePassword(password) {
            passwordErrorLabel.text = errorMessage
            passwordErrorLabel.isHidden = false
        } else {
            passwordErrorLabel.isHidden = true
        }
        
        if let errorMessage = viewModel.validatePasswordAndConfirmPassword(password, confirmPassword) {
            confirmPasswordErrorLabel.text = errorMessage
            confirmPasswordErrorLabel.isHidden = false
        } else {
            confirmPasswordErrorLabel.isHidden = true
        }
        
        guard viewModel.validateForm(emailErrorLabel, passwordErrorLabel, confirmPasswordErrorLabel) == true else {return}
        viewModel.signupUser(email: email, password: password, view:  self)
    }
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Private Methods
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func setupUserInterface() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        emailErrorLabel.isHidden = true
        passwordErrorLabel.isHidden = true
        confirmPasswordErrorLabel.isHidden = true
        
        signupButton.layer.cornerRadius = 12
        loginButton.layer.cornerRadius = 8
    }
}
