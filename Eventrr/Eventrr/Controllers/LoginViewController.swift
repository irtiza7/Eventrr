//
//  LoginViewController.swift
//  Eventrr
//
//  Created by Dev on 8/1/24.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var emailErrorLabel: UILabel!
    
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var passwordErrorLabel: UILabel!
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var resgiterButton: UIButton!
    
    // MARK: - Private Properties
    
    private let viewModel = LoginViewModel()
    
    // MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUserInterface()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
    }
    
    // MARK: - IBActions
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        guard let email = emailField.text,
              let password = passwordField.text else {return}
        
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
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
        
        guard viewModel.validateForm(emailErrorLabel, passwordErrorLabel) == true else {return}
        viewModel.loginUser(email: email, password: password, parentView: self)
    }
    
    @IBAction func forgotPassswordButtonPressed(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: K.StoryboardIdentifiers.mainBundleStoryboard, bundle: nil)
        let forgotViewController = storyboard.instantiateViewController(withIdentifier: K.StoryboardIdentifiers.forgotPasswordViewController) as! ForgotPasswordViewController
        
        if let email = emailField.text {
            forgotViewController.userEmail = email
        }
        navigationController?.pushViewController(forgotViewController, animated: true)
    }
    
    
    @IBAction func registerButtonPressed(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: K.StoryboardIdentifiers.mainBundleStoryboard, bundle: nil)
        let signupViewController = storyboard.instantiateViewController(withIdentifier: K.StoryboardIdentifiers.signupViewController)
        
        navigationController?.pushViewController(signupViewController, animated: true)
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
        
        loginButton.layer.cornerRadius = 12
        resgiterButton.layer.cornerRadius = 8
    }
}
