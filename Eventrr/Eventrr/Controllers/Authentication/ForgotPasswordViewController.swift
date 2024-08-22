//
//  ForgotPasswordViewController.swift
//  Eventrr
//
//  Created by Dev on 8/3/24.
//

import UIKit
import Combine

class ForgotPasswordViewController: UIViewController {
    
    static let identifier = String(describing: ForgotPasswordViewController.self)
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var emailErrorLabel: UILabel!
    @IBOutlet weak var sendResetLinkButton: UIButton!
    
    // MARK: - Public Properties
    
    private let spinner = Popups.loadingPopup()
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Public Properties
    
    public let viewModel = ForgotPasswordViewModel()
    
    // MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUserInterface()
        setupSubscriptions()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
    }
    
    // MARK: - IBActions
    
    @IBAction func sendResetLinkButtonPressed(_ sender: UIButton) {
        guard let email = emailField.text else {return}
        
        if let errorMessage = ValidationUtility.validateEmail(email) {
            emailErrorLabel.text = errorMessage
            emailErrorLabel.isHidden = false
            return
        }
        
        emailErrorLabel.isHidden = true
        viewModel.userEmail = email
        
        present(spinner, animated: true)
        viewModel.sendPasswordResetEmail()
    }
    
    // MARK: - Private Methods
    
    private func setupSubscriptions() {
        viewModel.$sendPasswordResetEmailStatus
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (status: SendPasswordResetEmailStatus?) in
                guard let status, let self else {return}
                self.spinner.dismiss(animated: true)
                
                switch status {
                case .success(let message):
                    Popups.displaySuccess(message: message) { [weak self] popup in
                        self?.present(popup, animated: true)
                    }
                    
                case .failure(let errorMessage):
                    Popups.displayFailure(message: errorMessage) { [weak self] popup in
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
        
        emailField.text = viewModel.userEmail ?? ""
        emailErrorLabel.isHidden = true
        
        sendResetLinkButton.layer.cornerRadius = K.UI.defaultPrimaryCornerRadius
    }
}
