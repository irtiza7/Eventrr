//
//  EventsViewController.swift
//  Eventrr
//
//  Created by Dev on 8/9/24.
//

import UIKit
import Combine
import RealmSwift

class HomeViewController: UIViewController {
    
    static let identifier = String(describing: HomeViewController.self)
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var createEventButton: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Private Properties
    
    private let viewModel = HomeViewModel()
    private var cancellables: Set<AnyCancellable> = []
    private let spinner = Popups.loadingPopup()
    
    // MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSubscriptions()
        setupCategoryCollectionView()
        setupEventsTableView()
        
        guard let userRole = UserService.shared?.user.role,
              userRole == .Admin else {
            createEventButton.isHidden = true
            return
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        present(spinner, animated: true)
        viewModel.fetchAllEvents()
    }
    
    // MARK: - IBActions
    
    @IBAction func createEventButtonPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: K.EventsStoryboardIdentifiers.eventsBundle, bundle: nil)
        let navigationController = storyboard.instantiateViewController(
            withIdentifier: K.EventsStoryboardIdentifiers.createEventNavigationController
        )
        navigationController.modalPresentationStyle = .fullScreen
        navigationController.modalTransitionStyle = .coverVertical
        
        present(navigationController, animated: true)
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
                    Popups.displayFailure(message: errorMessage) { [weak self] popup in
                        self?.present(popup, animated: true)
                    }
                }
            }.store(in: &cancellables)
    }
    
    private func setupCategoryCollectionView() {
        categoryCollectionView.delegate = self
        categoryCollectionView.dataSource = self
        
        categoryCollectionView.register(
            UINib(
                nibName: FilterTagCollectionViewCell.identifier,
                bundle: nil
            ),
            forCellWithReuseIdentifier: FilterTagCollectionViewCell.identifier
        )
    }
    
    @objc func pullDownToFetchEvents() {
        viewModel.fetchAllEvents()
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
        var eventAttendees: [EventAttendeeModel] = []
        for attendee in realmAttendees {
            eventAttendees.append(EventAttendeeModel(attendeeId: attendee.attendeeId))
        }
        return eventAttendees
    }
}

// MARK: - TableView Delegate Methods

extension HomeViewController: UITableViewDelegate {
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

// MARK: - TableView Data Source Methods

extension HomeViewController: UITableViewDataSource {
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

// MARK: - CollectionView Delegate Methods

extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        searchBar.endEditing(true)
        searchBar.text = ""
        
        let selectedCategory = viewModel.categoriesList[indexPath.row]
        viewModel.selectedCategory = selectedCategory
        categoryCollectionView.reloadData()
        
        if selectedCategory == EventCategoryFilter.All {
            viewModel.fetchAllEvents()
        } else {
            viewModel.filterEventsByCategory()
        }
    }
}

// MARK: - CollectionView Data Source Methods

extension HomeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.categoriesList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: FilterTagCollectionViewCell.identifier,
            for: indexPath) as? FilterTagCollectionViewCell {
            
            let selectedCategoryIndex = viewModel.categoriesList.firstIndex(of: viewModel.selectedCategory)
            
            if selectedCategoryIndex == indexPath.row {
                cell.filterLabel.textColor = UIColor(named: K.ColorConstants.BlackPrimary.rawValue)
                cell.filterLabel.font = .systemFont(ofSize: 13, weight: .heavy)
            } else {
                cell.filterLabel.textColor = UIColor(named: K.ColorConstants.WhitePrimary.rawValue)
                cell.filterLabel.font = .systemFont(ofSize: 13, weight: .semibold)
            }
            
            cell.filterLabel.text = viewModel.categoriesList[indexPath.row].rawValue
            return cell
        }
        return UICollectionViewCell()
    }
}


// MARK: - Searchbar Delegate Methods

extension HomeViewController: UISearchBarDelegate {
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
        viewModel.fetchAllEvents()
    }
}
