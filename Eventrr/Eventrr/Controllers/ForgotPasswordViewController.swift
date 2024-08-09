//
//  ForgotPasswordViewController.swift
//  Eventrr
//
//  Created by Dev on 8/3/24.
//

import UIKit

class ForgotPasswordViewController: UIViewController {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var emailErrorLabel: UILabel!
    
    @IBOutlet weak var sendResetLinkButton: UIButton!
    @IBOutlet weak var backToLoginButton: UIButton!
    
    // MARK: - Private Properties
    
    private let viewModel = ForgotPasswordViewModel()
    
    // MARK: - Public Properties
    
    public var userEmail: String?
    
    // MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUserInterface()
    }
    
    // MARK: - IBActions
    
    @IBAction func sendResetLinkButtonPressed(_ sender: UIButton) {
        guard let email = emailField.text else {return}
        
        if let errorMessage = viewModel.validateEmail(email) {
            emailErrorLabel.text = errorMessage
            emailErrorLabel.isHidden = false
        }
        
        emailErrorLabel.isHidden = true
        viewModel.sendPasswordResetEmail(email: email, view: self)
    }
    
    @IBAction func backToLoginButtonPressed(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    // MARK: - Private Methods
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func setupUserInterface() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        emailField.text = userEmail ?? ""
        emailErrorLabel.isHidden = true
        
        sendResetLinkButton.layer.cornerRadius = 12
        backToLoginButton.layer.cornerRadius = 12
    }
}
