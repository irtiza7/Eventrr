//
//  NameAndRoleViewController.swift
//  Eventrr
//
//  Created by Dev on 8/5/24.
//

import UIKit

class NameAndRoleViewController: UIViewController {
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var nameErrorLabel: UILabel!
    
    @IBOutlet weak var userTypePickerView: UIPickerView!
    @IBOutlet weak var userTypeErrorLabel: UILabel!
    
    @IBOutlet weak var saveButton: UIButton!
    
    // MARK: - Private Properties
    
    private let viewModel = NameAndRoleViewModel()
    private var userTypes = ["Admin", "Attendee"]
    private var selectedUserType: String = ""
    
    
    deinit {
        
    }
    
    // MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userTypePickerView.delegate = self
        userTypePickerView.dataSource = self
        
        setupInterface()
    }
    
    // MARK: - IBActions
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        guard let name = nameField.text else {return}
        
        if name == "" {
            nameErrorLabel.text = K.AuthConstants.requiredFieldString
            nameErrorLabel.isHidden = false
        } else {
            nameErrorLabel.isHidden = true
        }
        
        if selectedUserType == "" {
            userTypeErrorLabel.text = K.AuthConstants.requiredFieldString
            userTypeErrorLabel.isHidden = false
        } else {
            userTypeErrorLabel.isHidden = true
        }
        
        guard viewModel.validateForm(nameErrorLabel, userTypeErrorLabel) == true else {return}
        viewModel.saveUserInformation(name: name, userType: selectedUserType, view: self)
    }
    
    // MARK: - Private Methods
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func setupInterface() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        userTypePickerView.layer.borderWidth = 1
        userTypePickerView.layer.cornerRadius = 8
        if let accentPrimaryColor = UIColor(named: K.ColorConstants.AccentPrimary.rawValue) {
            userTypePickerView.layer.borderColor = accentPrimaryColor.cgColor
        } else {
            userTypePickerView.layer.borderColor = UIColor.black.cgColor
        }
        
        nameErrorLabel.isHidden = true
        userTypeErrorLabel.isHidden = true
        saveButton.layer.cornerRadius = 12
    }
}

// MARK: - UIPickerView Data Source Methods

extension NameAndRoleViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        userTypes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        userTypes[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedUserType = userTypes[row]
    }
}

// MARK: - UIPickerView Delegate Methods

extension NameAndRoleViewController: UIPickerViewDelegate {}
