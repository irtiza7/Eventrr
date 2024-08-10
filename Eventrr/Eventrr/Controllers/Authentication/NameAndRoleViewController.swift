//
//  NameAndRoleViewController.swift
//  Eventrr
//
//  Created by Dev on 8/5/24.
//

import UIKit

class NameAndRoleViewController: UIViewController {
    
    static let identifier = String(describing: NameAndRoleViewController.self)
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var nameErrorLabel: UILabel!
    @IBOutlet weak var userTypePickerView: UIPickerView!
    @IBOutlet weak var userTypeErrorLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    
    // MARK: - Private Properties
    
    private let viewModel = NameAndRoleViewModel()
    
    // MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userTypePickerView.delegate = self
        userTypePickerView.dataSource = self
        setupInterface()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
    }
    
    // MARK: - IBActions
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        guard let name = nameField.text else { return }
        
        if name == "" {
            nameErrorLabel.text = K.StringMessages.requiredFieldString
            nameErrorLabel.isHidden = false
        } else {
            nameErrorLabel.isHidden = true
        }
        
        guard viewModel.validateForm(nameErrorLabel, userTypeErrorLabel) == true else {return}
        saveAndNavigate(name: name)
//        viewModel.saveUserInformation(name: name, userType: selectedUserType, view: self)
    }
    
    // MARK: - Private Methods
    
    private func saveAndNavigate(name: String) {
        let spinner = Popups.loadingPopup()
        present(spinner, animated: true)
        
        Task {
            do {
                try await viewModel.saveUserInformation(name: name)
                spinner.dismiss(animated: true)
                
                let storyboard = UIStoryboard(name: K.EventsStoryboardIdentifiers.eventsBundle, bundle: nil)
                let viewController = storyboard.instantiateViewController(withIdentifier: K.EventsStoryboardIdentifiers.mainTabViewController)
                navigationController?.pushViewController(viewController, animated: true)
            } catch {
                spinner.dismiss(animated: true)
                
                print("[\(NameAndRoleViewController.identifier)] - Error: \n\(error)]")
                Popups.displayFailure(message: K.StringMessages.somethingWentWrong) { [weak self] popup in
                    self?.present(popup, animated: true)
                }
            }
        }
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func setupInterface() {
        navigationController?.isNavigationBarHidden = false
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        userTypePickerView.layer.borderWidth = K.UI.defaultPrimaryBorderWidth
        userTypePickerView.layer.cornerRadius = K.UI.defaultSecondardCornerRadius
        
        if let accentPrimaryColor = UIColor(named: K.ColorConstants.AccentPrimary.rawValue) {
            userTypePickerView.layer.borderColor = accentPrimaryColor.cgColor
        } else {
            userTypePickerView.layer.borderColor = UIColor.black.cgColor
        }
        
        nameErrorLabel.isHidden = true
        userTypeErrorLabel.isHidden = true
        saveButton.layer.cornerRadius = K.UI.defaultPrimaryCornerRadius
    }
}

// MARK: - UIPickerView Data Source Methods

extension NameAndRoleViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        viewModel.userRoles.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        viewModel.userRoles[row].rawValue
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        viewModel.selectedUserRole = viewModel.userRoles[row]
    }
}

// MARK: - UIPickerView Delegate Methods

extension NameAndRoleViewController: UIPickerViewDelegate {}
