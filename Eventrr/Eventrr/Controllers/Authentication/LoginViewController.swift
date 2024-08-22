//
//  LoginViewController.swift
//  Eventrr
//
//  Created by Dev on 8/1/24.
//

import UIKit
import FirebaseAuth
import Combine

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
    private let spinner = Popups.loadingPopup()
    private var cancellables: Set<AnyCancellable> = []
    private var presentingForFirstTime = true
    
    // MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUserInterface()
        setupSubscriptions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if presentingForFirstTime {
            presentingForFirstTime = false
            viewModel.checkUserLoggedInStatus()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = false
    }
    
    // MARK: - IBActions
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        guard let email = emailField.text,
              let password = passwordField.text else {return}
        
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
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
        
        guard viewModel.validateForm(emailErrorLabel, passwordErrorLabel) == true else {return}
        
        present(spinner, animated: true)
        viewModel.loginUser(email: email, password: password)
    }
    
    @IBAction func forgotPassswordButtonPressed(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: K.MainStoryboardIdentifiers.mainBundle, bundle: nil)
        let viewController = storyboard.instantiateViewController(
            withIdentifier: ForgotPasswordViewController.identifier
        ) as! ForgotPasswordViewController
        
        if let email = emailField.text {
            viewController.viewModel.userEmail = email
        }
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    
    @IBAction func registerButtonPressed(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: K.MainStoryboardIdentifiers.mainBundle, bundle: nil)
        let viewController = storyboard.instantiateViewController(
            withIdentifier: SignupViewController.identifier
        )
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    // MARK: - Private Methods
    
    private func setupSubscriptions() {
        viewModel.$isUserAlreadyLoggedIn
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (status: IsUserAlreadyLoggedIn?) in
                guard let status else {return}
                guard let self else {return}
                
                switch status {
                case .loggedIn:
                    self.viewModel.validateUserRequiredInformation()
                case .failure(let errorMessage):
                    Popups.displayFailure(
                        title: K.StringMessages.loginFailurePopupTitle,
                        message: errorMessage) { [weak self] popup in
                            self?.present(popup, animated: true)
                        }
                }
                
            }
            .store(in: &cancellables)
        
        viewModel.$loginStatus
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (status: LoginStatus?) in
                guard let status else {return}
                guard let self else {return}
                
                self.spinner.dismiss(animated: true)
                
                switch status {
                case .success:
                    self.viewModel.validateUserRequiredInformation()
                    
                case .failure(let errorMessage):
                    Popups.displayFailure(
                        title: K.StringMessages.loginFailurePopupTitle,
                        message: errorMessage) { [weak self] popup in
                            self?.present(popup, animated: true)
                        }
                }
            }.store(in: &cancellables)
        
        viewModel.$userInformationStatus
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (status: UserInformationStatus?) in
                guard let status else {return}
                guard let self else {return}
                
                self.spinner.dismiss(animated: true)
                
                switch status {
                case .saved:
                    let storyboard = UIStoryboard(name: K.EventsStoryboardIdentifiers.eventsBundle, bundle: nil)
                    let viewController = storyboard.instantiateViewController(withIdentifier: K.EventsStoryboardIdentifiers.mainTabViewController)
                    self.navigationController?.pushViewController(viewController, animated: true)
                    
                case .notSaved:
                    let storyboard = UIStoryboard(name: K.MainStoryboardIdentifiers.mainBundle, bundle: nil)
                    let viewController = storyboard.instantiateViewController(withIdentifier: NameAndRoleViewController.identifier)
                    self.navigationController?.pushViewController(viewController, animated: true)
                    
                case .failure(let errorMessage):
                    Popups.displayFailure(
                        title: K.StringMessages.loginFailurePopupTitle,
                        message: errorMessage
                    ) { [weak self] popup in
                        self?.present(popup, animated: true)
                    }
                }
            }.store(in: &cancellables)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func setupUserInterface() {
        navigationController?.isNavigationBarHidden = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        emailErrorLabel.isHidden = true
        passwordErrorLabel.isHidden = true
        
        loginButton.layer.cornerRadius = K.UI.defaultPrimaryCornerRadius
        resgiterButton.layer.cornerRadius = K.UI.defaultSecondardCornerRadius
    }
}
