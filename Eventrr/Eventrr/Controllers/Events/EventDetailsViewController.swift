//
//  EventDetailsViewController.swift
//  Eventrr
//
//  Created by Dev on 8/22/24.
//

import UIKit
import CoreLocation
import MapKit
import Combine

class EventDetailsViewController: UIViewController {
    
    static let identifier = String(describing: EventDetailsViewController.self)
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var eventTitleLabel: UILabel!
    @IBOutlet weak var ownerLabel: UILabel!
    @IBOutlet weak var audienceLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var aboutEventTextView: UITextView!
    
    @IBOutlet weak var attendeeActionButton: UIButton!
    
    @IBOutlet weak var adminActionsStackView: UIStackView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    // MARK: - Private Properties
    
    private let spinner = Popups.loadingPopup()
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Public Properties
    
    public let viewModel = EventDetailsViewModel()

    // MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUserInterface()
        initEventDetailsUI()
        setupSubscriptions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
    }
    
    // MARK: - IBActions
    
    @IBAction func openInMapsButtonPressed(_ sender: UIButton) {
        guard let event = viewModel.selectedEvent else {return}
        
        guard let latitude = Double(event.latitude),
              let longitude = Double(event.longitude) else {return}
        
        let placename = event.locationName
        openMapForPlace(lat: latitude, long: longitude, placeName: placename)
    }
    
    @IBAction func primaryActionButtonPressed(_ sender: UIButton) {
        if viewModel.hasUserJoinedEvent {
            let actionTitles = [
                K.ButtonAndPopupActionTitle.leave,
                K.ButtonAndPopupActionTitle.cancel
            ]
            
            let actionStyles: [UIAlertAction.Style] = [
                .destructive,
                .cancel
            ]
            
            var actions: [(UIAlertController) -> ()] = []
            
            actions.append { [weak self] _ in
                guard let self = self else {return}
                self.present(self.spinner, animated: true)
                self.viewModel.leaveEvent()
            }
            
            actions.append { _ in }
            
            let popup = Popups.confirmationPopup(
                message: K.StringMessages.eventLeaveConfirmationMessage,
                popupStyle: .alert,
                actionTitles: actionTitles,
                actionStyles: actionStyles,
                actionHandlers: actions
            )
            
            present(popup, animated: true)
        } else {
            let actionTitles = [
                K.ButtonAndPopupActionTitle.join,
                K.ButtonAndPopupActionTitle.cancel
            ]
            
            let actionStyles: [UIAlertAction.Style] = [
                .default,
                .cancel
            ]
            
            var actions: [(UIAlertController) -> ()] = []
            
            actions.append { [weak self] _ in
                guard let self = self else {return}
                self.present(self.spinner, animated: true)
                self.viewModel.joinEvent()
            }
            
            actions.append { _ in }
            
            let popup = Popups.confirmationPopup(
                message: K.StringMessages.eventJoinConfirmationMessage,
                popupStyle: .alert,
                actionTitles: actionTitles,
                actionStyles: actionStyles,
                actionHandlers: actions
            )
            
            present(popup, animated: true)
        }
    }
    
    @IBAction func editButtonPressed(_ sender: UIButton) {
        guard let selectedEvent = viewModel.selectedEvent else {return}
        let storyboard = UIStoryboard(name: K.EventsStoryboardIdentifiers.eventsBundle, bundle: nil)
        
        guard let navigationController = storyboard.instantiateViewController(
            withIdentifier: K.EventsStoryboardIdentifiers.createEventNavigationController
        ) as? UINavigationController else {return}
        
        guard let createEventVC = navigationController.viewControllers.first as? CreateEventViewController else {return}
        
        createEventVC.viewModel.eventToEdit = selectedEvent
        navigationController.modalPresentationStyle = .fullScreen
        navigationController.modalTransitionStyle = .coverVertical
        present(navigationController, animated: true)
        
    }
    
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        let actionTitles = [
            K.ButtonAndPopupActionTitle.delete,
            K.ButtonAndPopupActionTitle.cancel
        ]
        
        let actionStyles: [UIAlertAction.Style] = [
            .destructive,
            .cancel
        ]
        
        var actions: [(UIAlertController) -> ()] = []
        
        actions.append { [weak self] _ in
            guard let self = self else {return}
            self.present(self.spinner, animated: true)
            self.viewModel.deleteEvent()
        }
        
        actions.append { _ in }
        
        let popup = Popups.confirmationPopup(
            message: K.StringMessages.eventDeletionConfirmationMessage,
            popupStyle: .alert,
            actionTitles: actionTitles,
            actionStyles: actionStyles,
            actionHandlers: actions
        )
        
        present(popup, animated: true)
    }
    
    // MARK: - Private Methods
    
    private func setupUserInterface() {
        if let user = UserService.shared?.user {
            attendeeActionButton.isHidden = user.role == .Admin
            adminActionsStackView.isHidden = user.role != .Admin || viewModel.selectedEvent?.ownerId != user.id
        } else {
            attendeeActionButton.isHidden = true
            adminActionsStackView.isHidden = true
        }
        
        if let userId = UserService.shared?.user.id, let attendees = viewModel.selectedEvent?.attendees {
            let isAttendee = attendees.contains { $0.attendeeId == userId }
            viewModel.hasUserJoinedEvent = isAttendee
            
            let buttonTitle = isAttendee ? K.ButtonAndPopupActionTitle.leave.uppercased() : K.ButtonAndPopupActionTitle.join.uppercased()
            var attributes: [NSAttributedString.Key: Any] = [:]
            
            if let primaryAccent = UIColor(named: K.ColorConstants.AccentPrimary.rawValue),
               let redAccent = UIColor(named: K.ColorConstants.AccentRed.rawValue),
               let textColor  = UIColor(named: K.ColorConstants.WhitePrimary.rawValue) {
                
                if isAttendee {
                    attributes  = [
                        .font: UIFont.systemFont(ofSize: 20, weight: .semibold),
                        .foregroundColor: textColor,
                        .backgroundColor: redAccent
                    ]
                    attendeeActionButton.backgroundColor = redAccent
                } else {
                    attributes  = [
                        .font: UIFont.systemFont(ofSize: 20, weight: .semibold),
                        .foregroundColor: textColor,
                        .backgroundColor: primaryAccent
                    ]
                }
                let attributedTitle = NSAttributedString(string: buttonTitle, attributes: attributes)
                attendeeActionButton.setAttributedTitle(attributedTitle, for: .normal)
            }
        }

        aboutEventTextView.isEditable = false
        aboutEventTextView.layer.cornerRadius = K.UI.defaultSecondardCornerRadius
        aboutEventTextView.layer.borderWidth = K.UI.defaultSecondaryBorderWidth
        aboutEventTextView.layer.borderColor = UIColor(named: K.ColorConstants.AccentPrimary.rawValue)?.cgColor
        
        attendeeActionButton.layer.cornerRadius = K.UI.defaultPrimaryCornerRadius
        editButton.layer.cornerRadius = K.UI.defaultPrimaryCornerRadius
        deleteButton.layer.cornerRadius = K.UI.defaultPrimaryCornerRadius
    }
    
    private func initEventDetailsUI() {
        guard let event = viewModel.selectedEvent else {return}
                
        eventTitleLabel.text = event.title
        ownerLabel.text = "Created by \(event.ownerName)"
        categoryLabel.text = event.category
        locationLabel.text = event.locationName
        aboutEventTextView.text = event.description
        
        let formattedDateTime = FormatUtility.formatDateAndTime(
            dateString: event.date,
            fromTimeString: event.fromTime,
            toTimeString: event.toTime
        )
        
        dateLabel.text = formattedDateTime.dateFormatted
        timeLabel.text = formattedDateTime.timeFormatted
    }
    
    private func setupSubscriptions() {
        viewModel.$deletionError
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (deletionStatus: DeleteStatus?) in
                DispatchQueue.main.async {
                    guard let deletionStatus else {return}
                    
                    self?.spinner.dismiss(animated: true)
                    
                    switch deletionStatus {
                    case .failure(let errorMessage):
                        Popups.displayFailure(message: errorMessage) { [weak self] alertVC in
                            self?.present(alertVC, animated: true)
                        }
                    case .success:
                        self?.navigationController?.popViewController(animated: true)
                    }
                }
            }.store(in: &cancellables)
        
        viewModel.$joinAndLeaveEventStatus
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (status: JoinAndLeaveEventStatus?) in
                guard let status, let self else {return}
                
                self.spinner.dismiss(animated: true)
                
                switch status {
                case .success:
                    self.navigationController?.popViewController(animated: true)
                    
                case .failure(let errorMessage):
                    Popups.displayFailure(message: errorMessage) { [weak self] alertVC in
                        self?.present(alertVC, animated: true)
                    }
                }
                
            }.store(in: &cancellables)
    }
    
    private func openMapForPlace(lat: Double, long: Double, placeName: String = "") {
        let latitude: CLLocationDegrees = lat
        let longitude: CLLocationDegrees = long

        let regionDistance: CLLocationDistance = 1000
        let coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        let regionSpan = MKCoordinateRegion(
            center: coordinates,
            latitudinalMeters: regionDistance,
            longitudinalMeters: regionDistance
        )
        
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = placeName
        mapItem.openInMaps(launchOptions: options)
    }
}
