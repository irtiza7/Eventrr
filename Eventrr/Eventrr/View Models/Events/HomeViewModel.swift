//
//  EventsViewModel.swift
//  Eventrr
//
//  Created by Dev on 8/9/24.
//

import Foundation
import RealmSwift

class HomeViewModel {
    
    static let identifier = String(describing: HomeViewModel.self)
    
    // MARK: - Private Properties
    
    private let realmService: RealmService
    private var cachedEvents: Results<EventRealmModel>?
    private var notificationToken: NotificationToken?
    
    // MARK: - Public Properties
    
    @Published public var eventsFetchAndFilterStatus: EventsFetchAndFilterStatus?
    public var events: [EventRealmModel] = []
    public let categoriesList: [EventCategoryFilter] = EventCategoryFilter.allCases
    public var selectedCategory: EventCategoryFilter = .All
    
    // MARK: - Initializers and Deinitializers
    
    init(realmService: RealmService = RealmService.shared!) {
        self.realmService = realmService
        setupSubscription()
    }
    
    deinit {
        notificationToken?.invalidate()
    }
    
    // MARK: - Private Methods
    
    private func applySelectedCategoryToSearchedEvents(_ searchedEvents: [EventRealmModel]) {
        if selectedCategory == .All {
            events = Array(searchedEvents)
        } else {
            events = Array(searchedEvents.filter { event in event.category == selectedCategory.rawValue })
        }
        eventsFetchAndFilterStatus = .success
    }
    
    
    // MARK: - Private Methods
    
    private func setupSubscription() {
        Task { @MainActor [weak self] in
            self?.cachedEvents = self?.realmService
                .fetchAllObjects(ofType: EventRealmModel.self)
                .sorted(byKeyPath: DatabaseTableColumns.Events.date.rawValue, ascending: true)
            
            self?.notificationToken = self?.cachedEvents?.observe { [weak self] changes in
                switch changes {
                case .initial(let initialResults):
                    self?.cachedEvents = initialResults
                    
                case .update(let updatedResults, _, _, _):
                    self?.cachedEvents = updatedResults
                    
                case .error(let error):
                    print("[\(HomeViewModel.identifier)] - Error: \n\(error)")
                }
                
                self?.filterEventsByCategory()
            }
        }
    }
    
    // MARK: - Public Methods
    
    public func fetchAllEvents() {
        Task { @MainActor [weak self] in
            self?.cachedEvents = self?.realmService
                .fetchAllObjects(ofType: EventRealmModel.self)
                .sorted(byKeyPath: DatabaseTableColumns.Events.date.rawValue, ascending: true)
            
            self?.filterEventsByCategory()
        }
    }
    
    public func filterEventsByCategory() {
        guard let cachedEvents = self.cachedEvents else { return }
        let cachedEventsAsArray = Array(cachedEvents)
        
        if selectedCategory == .All {
            events = cachedEventsAsArray
        } else {
            events = cachedEventsAsArray.filter { event in event.category == self.selectedCategory.rawValue }
        }
        eventsFetchAndFilterStatus = .success
    }
    
    public func filterEventsContaining(titleOrLocation: String) {
        guard let cachedEvents = self.cachedEvents else { return }
        var searchedEvents: [EventRealmModel] = []
        
        if titleOrLocation == "" {
            searchedEvents = Array(cachedEvents)
        } else {
            searchedEvents = cachedEvents.filter { event in
                let titleMatch = event.title.lowercased().contains(titleOrLocation.lowercased())
                let locationMatch = event.locationName.lowercased().contains(titleOrLocation.lowercased())
                return titleMatch || locationMatch
            }
        }
        applySelectedCategoryToSearchedEvents(searchedEvents)
    }
}

enum EventsFetchAndFilterStatus {
    case success, failure(errorMessage: String)
}
