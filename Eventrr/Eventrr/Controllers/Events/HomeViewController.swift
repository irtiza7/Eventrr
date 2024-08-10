//
//  EventsViewController.swift
//  Eventrr
//
//  Created by Dev on 8/9/24.
//

import UIKit

class HomeViewController: UIViewController {
    
    static let identifier = String(describing: HomeViewController.self)
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var createEventButton: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Private Properties
    
    private let viewModel = HomeViewModel()
    
    // MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categoryCollectionView.delegate = self
        categoryCollectionView.dataSource = self
        categoryCollectionView.register(
            UINib(
                nibName: FilterTagCollectionViewCell.identifier,
                bundle: nil),
            forCellWithReuseIdentifier: FilterTagCollectionViewCell.identifier
        )
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(
            UINib(
                nibName: EventTableViewCell.identifier,
                bundle: nil),
            forCellReuseIdentifier: EventTableViewCell.identifier
        )
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.tintColor = UIColor(named: K.ColorConstants.AccentPrimary.rawValue)
        tableView.refreshControl?.addTarget(
            self,
            action: #selector(callPullToRefresh),
            for: .valueChanged
        )
        
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
        fetchAllEvents()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //        navigationController?.isNavigationBarHidden = false
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
    
    @objc func callPullToRefresh() {
        Task {
            do {
                try await viewModel.fetchAllEvents()
                tableView.refreshControl?.endRefreshing()
                tableView.reloadData()
            } catch {
                print("[\(HomeViewController.identifier)] - Error \n\(error)")
                
                Popups.displayFailure(message: K.StringMessages.eventsFetchError) { [weak self] popup in
                    self?.present(popup, animated: true)
                }
            }
        }
    }
    
    private func fetchAllEvents() {
        let spinner = Popups.loadingPopup()
        present(spinner, animated: true)
        
        Task {
            do {
                try await viewModel.fetchAllEvents()
                spinner.dismiss(animated: true)
                tableView.reloadData()
            } catch {
                print("[\(HomeViewController.identifier)] - Error \n\(error)")

                spinner.dismiss(animated: true)
                Popups.displayFailure(message: K.StringMessages.eventsFetchError) { [weak self] popup in
                    self?.present(popup, animated: true)
                }
            }
        }
    }
    
    private func fetchEventsContaining(title: String) {
        let spinner = Popups.loadingPopup()
        present(spinner, animated: true)
        
        Task {
            do {
                try await viewModel.fetchEventsAgainstTitle(title)
                spinner.dismiss(animated: true)
                tableView.reloadData()
            } catch {
                print("[\(HomeViewController.identifier)] - Error \n\(error)")

                spinner.dismiss(animated: true)
                Popups.displayFailure(message: K.StringMessages.eventsFetchError) { [weak self] popup in
                    self?.present(popup, animated: true)
                }
            }
        }
    }
    
    private func fetchEventsAgainst(category: String) {
        let spinner = Popups.loadingPopup()
        present(spinner, animated: true)
        
        Task {
            do {
                try await viewModel.fetchEventsAgainstCategory(category)
                spinner.dismiss(animated: true)
                tableView.reloadData()
            } catch {
                print("[\(HomeViewController.identifier)] - Error \n\(error)")

                spinner.dismiss(animated: true)
                Popups.displayFailure(message: K.StringMessages.eventsFetchError) { [weak self] popup in
                    self?.present(popup, animated: true)
                }
            }
        }
    }
}

// MARK: - TableView Delegate Methods

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(viewModel.eventsList[indexPath.row])
    }
}

// MARK: - TableView Data Source Methods

extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.eventsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let event = viewModel.eventsList[indexPath.row]
        if let cell = tableView.dequeueReusableCell(
            withIdentifier: EventTableViewCell.identifier,
            for: indexPath) as? EventTableViewCell {
            
            cell.titleLabel.text = event.title
            cell.ownerLabel.text = event.ownerName
            cell.locationLabel.text = event.locationName
            cell.categoryLabel.text = event.category
            
            let formattedDataAndTime = Utility.formatDateAndTime(
                dateString: event.date,
                fromTimeString: event.fromTime,
                toTimeString: event.toTime
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
        let category = viewModel.categoriesList[indexPath.row]
        
        if category == EventCategoryFilter.All {
            fetchAllEvents()
        } else {
            fetchEventsAgainst(category: category.rawValue)
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
            
            cell.filterLabel.text = viewModel.categoriesList[indexPath.row].rawValue
            return cell
        }
        return UICollectionViewCell()
    }
}


// MARK: - Searchbar Delegate Methods

extension HomeViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard searchText.count > 2 else {return}
        fetchEventsContaining(title: searchText)
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
        fetchAllEvents()
    }
}
