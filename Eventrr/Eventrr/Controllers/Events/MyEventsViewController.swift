//
//  MyEventsViewController.swift
//  Eventrr
//
//  Created by Irtiza on 8/25/24.
//

import UIKit
import Combine
import RealmSwift

class MyEventsViewController: UIViewController {
    
    static let identifier = String(describing: MyEventsViewController.self)
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Private Properties
    
    private let viewModel = MyEventsViewModel()
    private var cancellabels: Set<AnyCancellable> = []
    private let spinner = PopupService.loadingPopup()
    
    // MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        setupEventsTableView()
        setupSubscriptions()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        present(spinner, animated: true)
        viewModel.fetchEvents()
    }
    
    // MARK: - IBActions
    
    @IBAction func segmentedControlClicked(_ sender: UISegmentedControl) {
        searchBar.endEditing(true)
        searchBar.text = ""
        
        switch segmentedControl.selectedSegmentIndex {
        case 0: viewModel.selectedFilter = .All
        case 1: viewModel.selectedFilter = .Past
        case 2: viewModel.selectedFilter = .Future
        default: break
        }
        viewModel.filterEvents()
    }
    
    // MARK: - Private Methods
    
    private func setupSubscriptions() {
        viewModel.$eventsFetchAndFilterStatus
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (status: EventsFetchAndFilterStatus?) in
                guard let status, let self else {return}
                
                self.spinner.dismiss(animated: true)
                self.tableView.refreshControl?.endRefreshing()
                
                switch status {
                case .success:
                    self.tableView.reloadData()
                    
                case .failure(let errorMessage):
                    PopupService.displayFailure(message: errorMessage) { [weak self] popup in
                        self?.present(popup, animated: true)
                    }
                }
                
            }.store(in: &cancellabels)
    }
    
    @objc func pullDownToFetchEvents() {
        viewModel.fetchEvents()
    }
    
    private func setupEventsTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(
            UINib(nibName: EventTableViewCell.identifier, bundle: nil),
            forCellReuseIdentifier: EventTableViewCell.identifier
        )
        tableView.register(
            UINib(nibName: NoEventTableViewCell.identifier, bundle: nil),
            forCellReuseIdentifier: NoEventTableViewCell.identifier
        )
        
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.tintColor = UIColor(named: K.ColorConstants.AccentPrimary.rawValue)
        tableView.refreshControl?.addTarget(self, action: #selector(pullDownToFetchEvents), for: .valueChanged)
    }
    
    private func convertRealmAttendeesToEventAttendees(_ realmAttendees: List<EventAttendeeRealmModel>) -> [EventAttendeeModel] {
        return realmAttendees.map { realmAttendee in
            EventAttendeeModel(attendeeId: realmAttendee.attendeeId)
        }
    }
}

// MARK: - TableView Delegate Methods

extension MyEventsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if viewModel.events.count == 0 {return}
        
        let storyboard = UIStoryboard(name: K.EventsStoryboardIdentifiers.eventsBundle, bundle: nil)
        let viewController =  storyboard.instantiateViewController(
            withIdentifier: EventDetailsViewController.identifier
        ) as! EventDetailsViewController
        
        let eventRealmModel = viewModel.events[indexPath.row]
        guard eventRealmModel.isInvalidated != true else {return}
        
        let eventModel = EventModel(
            id: eventRealmModel.id,
            title: eventRealmModel.title,
            category: eventRealmModel.category,
            date: FormatUtility.convertDateToString(date: eventRealmModel.date),
            fromTime: FormatUtility.convertDateToString(date: eventRealmModel.fromTime),
            toTime: FormatUtility.convertDateToString(date: eventRealmModel.toTime),
            description: eventRealmModel.eventDescription,
            locationName: eventRealmModel.locationName,
            latitude: String(eventRealmModel.latitude),
            longitude: String(eventRealmModel.longitude),
            ownerId: eventRealmModel.ownerId,
            ownerName: eventRealmModel.ownerName,
            attendees: convertRealmAttendeesToEventAttendees(eventRealmModel.attendees)
        )
        
        viewController.viewModel.selectedEvent = eventModel
        navigationController?.pushViewController(viewController, animated: true)
    }
}

// MARK: - TableView Datasource Methods

extension MyEventsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.events.count == 0 ? 1 : viewModel.events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if viewModel.events.count == 0 {
            if let cell = tableView.dequeueReusableCell(
                withIdentifier: NoEventTableViewCell.identifier,
                for: indexPath
            ) as? NoEventTableViewCell {
                return cell
            } else {
                return UITableViewCell()
            }
        }
        
        let event = viewModel.events[indexPath.row]
        if let cell = tableView.dequeueReusableCell(
            withIdentifier: EventTableViewCell.identifier,
            for: indexPath
        ) as? EventTableViewCell {
            
            cell.titleLabel.text = event.title
            cell.ownerLabel.text = event.ownerName
            cell.locationLabel.text = event.locationName
            cell.categoryLabel.text = event.category
            
            let formattedDataAndTime = FormatUtility.formatDateAndTime(
                dateString: FormatUtility.convertDateToString(date: event.date),
                fromTimeString: FormatUtility.convertDateToString(date: event.fromTime),
                toTimeString: FormatUtility.convertDateToString(date: event.toTime)
            )
            
            cell.dateLabel.text = formattedDataAndTime.dateFormatted
            cell.timeLabel.text = formattedDataAndTime.timeFormatted
            return cell
        }
        return UITableViewCell()
    }
}

// MARK: - Searchbar Delegate Methods

extension MyEventsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.filterEventsContaining(titleOrLocation: searchText)
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.showsCancelButton = true
        return true
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.showsCancelButton = false
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        searchBar.text = ""
        viewModel.fetchEvents()
    }
}
