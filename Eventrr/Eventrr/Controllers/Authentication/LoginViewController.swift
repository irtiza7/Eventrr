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
    
    override func viewWillAppear(_ animated: Bool) {
        alreadyLoggedInNavigation()
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
        
        if let errorMessage = Utility.validateEmail(email) {
            emailErrorLabel.text = errorMessage
            emailErrorLabel.isHidden = false
        } else {
            emailErrorLabel.isHidden = true
        }
        
        if let errorMessage = Utility.validatePassword(password) {
            passwordErrorLabel.text = errorMessage
            passwordErrorLabel.isHidden = false
        } else {
            passwordErrorLabel.isHidden = true
        }
        
        guard viewModel.validateForm(emailErrorLabel, passwordErrorLabel) == true else {return}
        loginUser(email: email, password: password)
    }
    
    @IBAction func forgotPassswordButtonPressed(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: K.MainStoryboardIdentifiers.mainBundle, bundle: nil)
        let viewController = storyboard.instantiateViewController(
            withIdentifier: ForgotPasswordViewController.identifier
        ) as! ForgotPasswordViewController
        
        if let email = emailField.text {
            viewController.userEmail = email
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
    
    private func alreadyLoggedInNavigation() {
        Task {
            if await viewModel.checkUserLoggedInStatus() {
                let storyboard = UIStoryboard(
                    name: K.EventsStoryboardIdentifiers.eventsBundle,
                    bundle: nil
                )
                let viewController = storyboard.instantiateViewController(
                    withIdentifier: K.EventsStoryboardIdentifiers.mainTabViewController
                )
                navigationController?.pushViewController(viewController, animated: true)
            }
        }
    }
    
    private func loginUser(email: String, password: String) {
        let spinner = Popups.loadingPopup()
        present(spinner, animated: true)
        
        Task {
            do {
                let _  = try await viewModel.loginUser(email: email, password: password)
                spinner.dismiss(animated: true)
                showNextViewController()
            } catch {
                spinner.dismiss(animated: true)
                
                print("[LoginViewController] - Error: \n\(error)]")
                guard let parsedError = FirebaseService.shared.parseLoginError(error as NSError) else {return}
                
                Popups.displayFailure(
                    title: K.StringMessages.loginFailurePopupTitle,
                    message: parsedError.message) {[weak self] popup in
                        self?.present(popup, animated: true)
                    }
            }
        }
    }
    
    private func showNextViewController() {
        Task {
            do {
                /*
                 Checking if the Users collection contains a record
                 containing authenticated user's required information
                 */
                let validityStatus = try await viewModel.validateUserRequiredInformation()
                
                let storyboard = validityStatus ? UIStoryboard(
                    name: K.EventsStoryboardIdentifiers.eventsBundle,
                    bundle: nil
                ) : UIStoryboard(
                    name: K.MainStoryboardIdentifiers.mainBundle,
                    bundle: nil
                )
                
                let viewController = validityStatus ? storyboard.instantiateViewController(
                    withIdentifier: K.EventsStoryboardIdentifiers.mainTabViewController
                ) : storyboard.instantiateViewController(
                    withIdentifier: NameAndRoleViewController.identifier
                )
                
                navigationController?.pushViewController(viewController, animated: true)
                
            } catch {
                Popups.displayFailure(
                    title: K.StringMessages.errorTitle,
                    message: K.StringMessages.somethingWentWrong) {[weak self] popup in
                        self?.present(popup, animated: true)
                    }
            }
        }
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
