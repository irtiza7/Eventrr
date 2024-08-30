//
//  MyEventsViewModel.swift
//  Eventrr
//
//  Created by Irtiza on 8/25/24.
//

import Foundation
import RealmSwift

final class MyEventsViewModel {
    
    static let identifier = String(describing: MyEventsViewModel.self)
    
    // MARK: - Private Properties
    
    private let userService: UserServiceProtocol
    private let realmService: RealmService
    private var cachedEvents: Results<EventRealmModel>?
    private var notificationToken: NotificationToken?
    
    // MARK: - Public Properties
    
    @Published public var eventsFetchAndFilterStatus: EventsFetchAndFilterStatus?
    
    public var events: [EventRealmModel] = []
    public var selectedFilter: MyEventFilter = .All
    
    // MARK: - Initializers and Deinitializers
    
    init(userService: UserServiceProtocol = UserService.shared!, realmService: RealmService = RealmService.shared!) {
        self.userService = userService
        self.realmService = realmService
        
        setupSubscription()
    }
    
    deinit {
        notificationToken?.invalidate()
    }
    
    // MARK: - Private Methods
    
    private func setupSubscription() {
        guard let id = UserService.shared?.user.id else {
            eventsFetchAndFilterStatus = .failure(errorMessage: K.StringMessages.somethingWentWrong)
            return
        }
        
        Task { @MainActor in
            cachedEvents = realmService
                .fetchObjectsWhere(ofType: EventRealmModel.self, field: DatabaseTableColumns.Events.ownerId.rawValue, equalTo: id)
            
            notificationToken = cachedEvents?.observe { [weak self] changes in
                switch changes {
                case .initial(let initialResults):
                    self?.cachedEvents = initialResults
                    
                case .update(let updatedResults, _, _, _):
                    self?.cachedEvents = updatedResults
                    
                case .error(let error):
                    print("[\(HomeViewModel.identifier)] - Error: \n\(error)")
                }
                
                self?.filterEvents()
            }
        }
    }
    
    private func fetchAdminEvents() {
        guard let id = UserService.shared?.user.id else {
            eventsFetchAndFilterStatus = .failure(errorMessage: K.StringMessages.somethingWentWrong)
            return
        }
        
        Task { @MainActor in
            cachedEvents = realmService
                .fetchObjectsWhere(
                    ofType: EventRealmModel.self,
                    field: DatabaseTableColumns.Events.ownerId.rawValue,
                    equalTo: id
                )
            filterEvents()
        }
    }
    
    private func fetchAttendeeEvents() {
        guard let attendeeId = UserService.shared?.user.id else {
            eventsFetchAndFilterStatus = .failure(errorMessage: K.StringMessages.somethingWentWrong)
            return
        }
        
        Task { @MainActor in
            cachedEvents = realmService
                .fetchObjectsWhereArraySubfield(
                    ofType: EventRealmModel.self,
                    arrayField: DatabaseTableColumns.Events.attendees.rawValue,
                    subField: DatabaseTableColumns.EventAttendees.attendeeId.rawValue,
                    equalTo: attendeeId
                )
            filterEvents()
        }
    }
    
    private func applySelectedFilterToSearchedEvents(_ searchedEvents: [EventRealmModel]) {
        switch selectedFilter {
        case .All:
            events = searchedEvents
            
        case .Past:
            events = searchedEvents.filter { event in
                return Date() > event.date
            }
            
        case .Future:
            events = searchedEvents.filter { event in
                return Date() < event.date
            }
        }
        eventsFetchAndFilterStatus = .success
    }
    
    // MARK: - Public Methods
    
    public func fetchEvents() {
        guard let role = userService.user.role else {
            eventsFetchAndFilterStatus = .failure(errorMessage: K.StringMessages.eventsFetchError)
            return
        }
        role == .Admin ? fetchAdminEvents() : fetchAttendeeEvents()
    }
    
    public func filterEvents() {
        guard let cachedEvents else {return}
        
        switch selectedFilter {
        case .All:
            events = Array(cachedEvents)
        case .Past:
            events = cachedEvents.filter { event in
                return Date() > event.date
            }
        case .Future:
            events = cachedEvents.filter { event in
                return Date() < event.date
            }
        }
        eventsFetchAndFilterStatus = .success
    }
    
    public func filterEventsContaining(titleOrLocation: String) {
        guard let cachedEvents else {return}
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
        applySelectedFilterToSearchedEvents(searchedEvents)
    }
}
