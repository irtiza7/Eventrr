//
//  CreateEventViewController.swift
//  Eventrr
//
//  Created by Dev on 8/9/24.
//

import UIKit
import Combine

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
    
    private var cancellables: Set<AnyCancellable> = []
    private let spinner = Popups.loadingPopup()
    
    // MARK: - Public Properties
    
    public let viewModel = CreateEventViewModel()
    
    // MARK: - Initializers
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categoryPicker.delegate = self
        categoryPicker.dataSource = self
        
        setupInterface()
        setupSubscriptions()
        
        if let event = viewModel.eventToEdit {
            initEditEventDetailsUI(with: event)
        }
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
        let titles = [viewModel.eventToEdit == nil ? K.ButtonAndPopupActionTitle.create : K.ButtonAndPopupActionTitle.update,
                      K.ButtonAndPopupActionTitle.saveAsDraft,
                      K.ButtonAndPopupActionTitle.continueEditing]
        
        let styles = [UIAlertAction.Style.default,
                      UIAlertAction.Style.default,
                      UIAlertAction.Style.cancel]
        
        var actions: [(UIAlertController) -> ()] = []
        
        /* Handler for "Create" or "Update */
        actions.append {
            [weak self] _ in
            self?.createOrUpdateEvent()
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
        let titles = [K.ButtonAndPopupActionTitle.discard,
                      K.ButtonAndPopupActionTitle.saveAsDraft,
                      K.ButtonAndPopupActionTitle.continueEditing]
        
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
    
    private func setupSubscriptions() {
        viewModel.$eventCreateAndUpdateStatus
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (status: EventCreateAndUpdateStatus?) in
                guard let status, let self else {return}
                
                self.spinner.dismiss(animated: true)
                
                switch status {
                case .success:
                    self.navigationController?.dismiss(animated: true)
                
                case .failure(let errorMessage):
                    Popups.displayFailure(message: errorMessage) { [weak self] popup in
                        self?.present(popup, animated: true)
                    }
                }
            }.store(in: &cancellables)
        
    }
    
    private func initEditEventDetailsUI(with event: EventModel) {
        titleTextField.text = event.title
        
        if let categoryIndex = EventCategory.allCases.firstIndex(of: EventCategory(rawValue: event.category)!) {
            categoryPicker.selectRow(categoryIndex, inComponent: 0, animated: false)
        }
        if let date = FormatUtility.convertStringToDate(dateString: event.date) {
            datePicker.date = date
        }
        if let date = FormatUtility.convertStringToDate(dateString: event.fromTime) {
            fromTimePicker.date = date
        }
        if let date = FormatUtility.convertStringToDate(dateString: event.toTime) {
            toTimePicker.date = date
        }
        
        locationLabel.text = event.locationName
        descriptionTextView.text = event.description
        
        viewModel.selectedEventCategory = EventCategory(rawValue: event.category)!
        
        guard let latitude = Double(event.latitude), let longitude = Double(event.longitude) else {return}
        
        let locationModel = LocationModel(name: event.locationName, latitude: latitude, longitude: longitude)
        viewModel.selectedLocation = locationModel
    }
    
    private func createOrUpdateEvent() {
        validateIndividualFields()
        guard isEventFormValid() == true else {return}
        
        guard let ownerId = UserService.shared?.user.id, let ownerName = UserService.shared?.user.name else {return}
        
        viewModel.event = EventModel(
            id: viewModel.eventToEdit?.id ?? nil,
            
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
        
        present(spinner, animated: true)
        
        if let _ = viewModel.eventToEdit {
            viewModel.updateEvent()
        } else {
            viewModel.createEvent()
        }
    }
    
    private func saveAsDraft() {
        print("draft")
    }
    
    private func validateIndividualFields() {
        /* Title Validation */
        if let errorMessage = ValidationUtility.validateTexualFieldContainsText(titleTextField.text) {
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
        if let errorMessage = ValidationUtility.validateTexualFieldContainsText(descriptionTextView.text) {
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
        guard let backgroundPrimaryColor = UIColor(named: K.ColorConstants.WhitePrimary.rawValue)?.cgColor else {return}
        
        let buttonTitle = viewModel.eventToEdit == nil ? K.ButtonAndPopupActionTitle.create.uppercased() : K.ButtonAndPopupActionTitle.update.uppercased()
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 20, weight: .semibold),
            .foregroundColor: backgroundPrimaryColor,
            .backgroundColor: accentPrimaryColor
        ]
        let attributedTitle = NSAttributedString(string: buttonTitle, attributes: attributes)
        createButton.setAttributedTitle(attributedTitle, for: .normal)
        
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
