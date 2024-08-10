//
//  CreateEventViewController.swift
//  Eventrr
//
//  Created by Dev on 8/9/24.
//

import UIKit

class CreateEventViewController: UIViewController {
    
    static let identifier = String(describing: CreateEventViewController.self)
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var titleTextField: UITextFieldDesignable!
    @IBOutlet weak var titleErrorLabel: UILabel!
    
    @IBOutlet weak var categoryPicker: UIPickerView!
    @IBOutlet weak var categoryErrorLabel: UILabel!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var dateErrorLabel: UILabel!
    
    @IBOutlet weak var fromTimePicker: UIDatePicker!
    @IBOutlet weak var toTimePicker: UIDatePicker!
    @IBOutlet weak var timeErrorLabel: UILabel!
    
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var locationErrorLabel: UILabel!
    
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var descriptionErrorLabel: UILabel!
    
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var discardButton: UIButton!
    
    // MARK: - Private Properties
    
    private let viewModel = CreateEventViewModel()
    
    // MARK: - Initializers
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categoryPicker.delegate = self
        categoryPicker.dataSource = self
        
        setupInterface()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = false
    }
    
    // MARK: - IBActions
    
    @IBAction func locationSetButtonPressed(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: K.EventsStoryboardIdentifiers.eventsBundle, bundle: nil)
        let viewController = storyboard.instantiateViewController(
            withIdentifier: SetEventLocationViewController.identifier
        ) as! SetEventLocationViewController
        
        viewController.delegate = self
        viewController.modalTransitionStyle = .coverVertical
        viewController.modalPresentationStyle = .fullScreen
        
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func createButtonPressed(_ sender: UIButton) {
        let titles = [K.PopupActionTitle.create,
                      K.PopupActionTitle.saveAsDraft,
                      K.PopupActionTitle.continueEditing]
        
        let styles = [UIAlertAction.Style.default,
                      UIAlertAction.Style.default,
                      UIAlertAction.Style.cancel]
        
        var actions: [(UIAlertController) -> ()] = []
        
        /* Handler for "Create" */
        actions.append {
            [weak self] _ in
            self?.createEvent()
        }
        
        /* Handler for "Save as Draft" */
        actions.append {
            [weak self] _ in
            self?.saveAsDraft()
        }
        
        /* Handler for "Continue Editing" */
        actions.append { (popup: UIAlertController) in
            popup.dismiss(animated: true)
        }
        
        let popup = Popups.confirmationPopup(
            popupStyle: .actionSheet,
            actionTitles: titles,
            actionStyles: styles,
            actionHandlers: actions
        )
        present(popup, animated: true)
    }
    
    @IBAction func discardButtonPressed(_ sender: UIButton) {
        let titles = [K.PopupActionTitle.discard,
                      K.PopupActionTitle.saveAsDraft,
                      K.PopupActionTitle.continueEditing]
        
        let styles = [UIAlertAction.Style.destructive,
                      UIAlertAction.Style.default,
                      UIAlertAction.Style.cancel]
        
        var actions: [(UIAlertController) -> ()] = []
        
        /* Handler for "Discard" */
        actions.append {
            [weak self] _ in
            self?.navigationController?.dismiss(animated: true)
        }
        
        /* Handler for "Save as Draft" */
        actions.append {
            [weak self] _ in
            self?.saveAsDraft()
        }
        
        /* Handler for "Continue Editing" */
        actions.append { (popup: UIAlertController) in
            popup.dismiss(animated: true)
        }
        
        let popup = Popups.confirmationPopup(
            popupStyle: .actionSheet,
            actionTitles: titles,
            actionStyles: styles,
            actionHandlers: actions
        )
        present(popup, animated: true)
    }
    
    // MARK: - Private Methods
    
    private func createEvent() {
        validateIndividualFields()
        guard isEventFormValid() == true else {return}
        
        guard let ownerId = UserService.shared?.user.id else {return}
        guard let ownerName = UserService.shared?.user.name else {return}
        
        let eventModel = EventModel(
            title: titleTextField.text!,
            category: viewModel.selectedEventCategory.rawValue,
            date: datePicker.date.description,
            fromTime: fromTimePicker.date.description,
            toTime: toTimePicker.date.description,
            description: descriptionTextView.text,
            locationName: viewModel.selectedLocation!.name,
            latitude: String(viewModel.selectedLocation!.latitude),
            longitude: String(viewModel.selectedLocation!.longitude),
            ownerId: ownerId,
            ownerName: ownerName
        )
        
        Task {
            let spinner = Popups.loadingPopup()
            present(spinner, animated: true)
            
            do {
                try await viewModel.saveEventToFirebase(event: eventModel)
                spinner.dismiss(animated: true)
                self.navigationController?.dismiss(animated: true)
            } catch {
                spinner.dismiss(animated: true)
                print("[\(CreateEventViewController.identifier)] - Error: \n\(error)")
                
                guard let parsedError = FirebaseService.shared.parseNetworkError(error as NSError) else  {return}
                
                Popups.displayFailure(message: parsedError.message) {[weak self] popup in
                    self?.present(popup, animated: true)
                }
                self.navigationController?.dismiss(animated: true)
            }
        }
    }
    
    private func saveAsDraft() {
        print("draft")
    }
    
    private func validateIndividualFields() {
        /* Title Validation */
        if let errorMessage = Utility.validateTexualFieldContainsText(titleTextField.text) {
            titleErrorLabel.text = errorMessage
            titleErrorLabel.isHidden = false
        } else {
            titleErrorLabel.text = ""
            titleErrorLabel.isHidden = true
        }
        
        /* Time Validation */
        if let errorMessage = viewModel.validateDateAndTime(
            selectedDate: datePicker.date,
            fromTime: fromTimePicker.date,
            toTime: toTimePicker.date
        ) {
            timeErrorLabel.text = errorMessage
            timeErrorLabel.isHidden = false
        } else {
            timeErrorLabel.text = ""
            timeErrorLabel.isHidden = true
        }
        
        /* Location Validation */
        if viewModel.selectedLocation == nil {
            locationErrorLabel.text = K.StringMessages.requiredFieldString
            locationErrorLabel.isHidden = false
        } else {
            locationErrorLabel.text = ""
            locationErrorLabel.isHidden = true
        }
        
        /* Description Validation */
        if let errorMessage = Utility.validateTexualFieldContainsText(descriptionTextView.text) {
            descriptionErrorLabel.text = errorMessage
            descriptionErrorLabel.isHidden = false
        } else {
            descriptionErrorLabel.text = ""
            descriptionErrorLabel.isHidden = true
        }
    }
    
    private func isEventFormValid() -> Bool {
        titleErrorLabel.isHidden && categoryErrorLabel.isHidden && dateErrorLabel.isHidden && timeErrorLabel.isHidden && locationErrorLabel.isHidden && descriptionErrorLabel.isHidden
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func setupInterface() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        titleErrorLabel.isHidden = true
        categoryErrorLabel.isHidden = true
        dateErrorLabel.isHidden = true
        timeErrorLabel.isHidden = true
        locationErrorLabel.isHidden = true
        descriptionErrorLabel.isHidden = true
        
        categoryPicker.layer.borderWidth = K.UI.defaultPrimaryBorderWidth
        categoryPicker.layer.cornerRadius = K.UI.defaultSecondardCornerRadius
        
        datePicker.minimumDate = Date()
        datePicker.layer.borderWidth = K.UI.defaultPrimaryBorderWidth
        datePicker.layer.cornerRadius = K.UI.defaultSecondardCornerRadius
        
        fromTimePicker.layer.borderWidth = K.UI.defaultPrimaryBorderWidth
        fromTimePicker.layer.cornerRadius = K.UI.defaultSecondardCornerRadius
        
        toTimePicker.layer.borderWidth = K.UI.defaultPrimaryBorderWidth
        toTimePicker.layer.cornerRadius = K.UI.defaultSecondardCornerRadius
        
        descriptionTextView.layer.borderWidth = K.UI.defaultPrimaryBorderWidth
        descriptionTextView.layer.cornerRadius = K.UI.defaultSecondardCornerRadius
        
        createButton.layer.cornerRadius = K.UI.defaultPrimaryCornerRadius
        discardButton.layer.cornerRadius = K.UI.defaultPrimaryCornerRadius
        
        guard let accentPrimaryColor = UIColor(named: K.ColorConstants.AccentPrimary.rawValue)?.cgColor else {return}
        
        categoryPicker.layer.borderColor = accentPrimaryColor
        datePicker.layer.borderColor = accentPrimaryColor
        fromTimePicker.layer.borderColor = accentPrimaryColor
        toTimePicker.layer.borderColor = accentPrimaryColor
        descriptionTextView.layer.borderColor = accentPrimaryColor
        
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(
            x: 0.0,
            y: locationLabel.frame.height - 1,
            width: locationLabel.frame.width,
            height: 1.0
        )
        bottomLine.backgroundColor = accentPrimaryColor
        locationLabel.layer.addSublayer(bottomLine)
    }
}

// MARK: - CreateEventViewController Delegate Methods

extension CreateEventViewController: CreateEventViewControllerDelegate {
    func didSelectEventLocation(location: LocationModel) {
        locationLabel.text = location.name
        viewModel.selectedLocation = location
    }
}

// MARK: - UIPickerView Data Source Methods

extension CreateEventViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        viewModel.eventCategories.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        viewModel.eventCategories[row].rawValue
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        viewModel.selectedEventCategory = viewModel.eventCategories[row]
    }
}

// MARK: - UIPickerView Delegate Methods

extension CreateEventViewController: UIPickerViewDelegate {}
