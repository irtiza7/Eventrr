//
//  EventsViewModel.swift
//  Eventrr
//
//  Created by Dev on 8/9/24.
//

import Foundation

class HomeViewModel {
    
    static let identifier = String(describing: HomeViewModel.self)
    
    // MARK: - Private Properties
    
    private let userService: UserServiceProtocol
    private let databaseService: FirebaseService
    private var cachedEvents: [EventModel] = []
//    private var eventAttendeesMapping: [String: UserEvent] = [:]
    
    // MARK: - Public Properties
    
    @Published public var eventsFetchAndFilterStatus: EventsFetchAndFilterStatus?
    public var events: [EventModel] = []
    public let categoriesList: [EventCategoryFilter] = EventCategoryFilter.allCases
    public var selectedCategory: EventCategoryFilter = .All
    
    // MARK: - Initializers
    
    init(userService: UserServiceProtocol = UserService.shared!,
         databaseService: FirebaseService = FirebaseService.shared) {
        self.userService = userService
        self.databaseService = databaseService
    }
    
    // MARK: - Pricate Methods
    
    private func applySelectedCategoryToSearchedEvents(_ searchedEvents: [EventModel]) {
        if selectedCategory == .All {
            events = searchedEvents
        } else {
            events = searchedEvents.filter { event in event.category == selectedCategory.rawValue }
        }
        eventsFetchAndFilterStatus = .success
    }
    
    private func fetchEventAttendees() {
        
    }
    
    // MARK: - Public Methods
    
    public func fetchAllEvents() {
        Task {
            do {
                let querySnapshot = try await databaseService.fetchAllData(
                    table: DatabaseTables.Events.rawValue
                )
                let documents = querySnapshot.documents
                
                var fetchedEvents: [EventModel] = []
                for document in documents {
                    let decodedEvent = try document.data(as: EventModel.self)
                    fetchedEvents.append(decodedEvent)
                }
                cachedEvents = fetchedEvents
                filterEventsByCategory()
            } catch {
                print("[\(HomeViewModel.identifier)] - Error \n\(error)")
                eventsFetchAndFilterStatus = .failure(errorMessage: K.StringMessages.eventsFetchError)
            }
        }
    }
    
    public func filterEventsByCategory() {
        if selectedCategory == .All {
            events = cachedEvents
        } else {
            events = cachedEvents.filter { event in event.category == selectedCategory.rawValue }
        }
        eventsFetchAndFilterStatus = .success
    }
    
    public func filterEventsContaining(titleOrLocation: String) {
        var searchedEvents: [EventModel] = []
        
        if titleOrLocation == "" {
            searchedEvents = cachedEvents
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
