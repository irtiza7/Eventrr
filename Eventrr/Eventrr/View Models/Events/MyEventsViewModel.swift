//
//  MyEventsViewModel.swift
//  Eventrr
//
//  Created by Irtiza on 8/25/24.
//

import Foundation
import FirebaseFirestore

final class MyEventsViewModel {
    
    static let identifier = String(describing: MyEventsViewModel.self)
    
    // MARK: - Private Properties
    
    private let userService: UserServiceProtocol
    private let databaseService: FirebaseService
    private var cachedEvents: [EventModel] = []
    
    // MARK: - Public Properties
    
    @Published public var eventsFetchAndFilterStatus: EventsFetchAndFilterStatus?
    
    public var events: [EventModel] = []
    public var selectedFilter: MyEventFilter = .All
    
    // MARK: - Initializers
    
    init(userService: UserServiceProtocol = UserService.shared!,
         databaseService: FirebaseService = FirebaseService.shared) {
        self.userService = userService
        self.databaseService = databaseService
    }
    
    // MARK: - Private Methods
    
    private func fetchAdminEvents() {
        guard let id = UserService.shared?.user.id else {
            eventsFetchAndFilterStatus = .failure(errorMessage: K.StringMessages.somethingWentWrong)
            return
        }
        
        Task {
            do {
                let querySnapshot = try await databaseService.fetchDataAgainst(
                    value: id,
                    column: DatabaseTableColumns.Events.ownerId.rawValue,
                    table: DatabaseTables.Events.rawValue
                )
                
                var fetchedEvents: [EventModel] = []
                for document in querySnapshot.documents {
                    let decodedEvent = try Firestore.Decoder().decode(EventModel.self, from: document.data())
                    fetchedEvents.append(decodedEvent)
                }
                
                cachedEvents = fetchedEvents
                filterEvents()
            } catch {
                print("[\(MyEventsViewModel.identifier)] - Error: \n\(error)")
                eventsFetchAndFilterStatus = .failure(errorMessage: K.StringMessages.eventsFetchError)
            }
        }
    }
    
    private func fetchAttendeeEvents() {
        guard let attendeeId = UserService.shared?.user.id else {
            eventsFetchAndFilterStatus = .failure(errorMessage: K.StringMessages.somethingWentWrong)
            return
        }
        
        Task {
            do {
                let data = [DatabaseTableColumns.EventAttendees.attendeeId.rawValue: attendeeId]
                print(data)
                let querySnapshot = try await databaseService.fetchAgainstArrayField(
                    containingData: data,
                    arrayFieldName: DatabaseTableColumns.Events.attendees.rawValue,
                    table: DatabaseTables.Events.rawValue
                )
                
                var fetchedEvents: [EventModel] = []
                for document in querySnapshot.documents {
                    let decodedEvent = try Firestore.Decoder().decode(EventModel.self, from: document.data())
                    fetchedEvents.append(decodedEvent)
                }
                
                cachedEvents = fetchedEvents
                filterEvents()
            } catch {
                print("[\(MyEventsViewModel.identifier)] - Error: \n\(error)")
                eventsFetchAndFilterStatus = .failure(errorMessage: K.StringMessages.eventsFetchError)
            }
        }
    }
    
    private func applySelectedFilterToSearchedEvents(_ searchedEvents: [EventModel]) {
        switch selectedFilter {
        case .All:
            events = searchedEvents
        
        case .Past:
            events = searchedEvents.filter { event in
                guard let eventDate = FormatUtility.convertStringToDate(dateString: event.date) else {return false}
                return Date() > eventDate
            }
        
        case .Future:
            events = searchedEvents.filter { event in
                guard let eventDate = FormatUtility.convertStringToDate(dateString: event.date) else {return false}
                return Date() < eventDate
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
        switch selectedFilter {
        case .All:
            events = cachedEvents
        case .Past:
            events = cachedEvents.filter { event in
                guard let eventDate = FormatUtility.convertStringToDate(dateString: event.date) else {return false}
                return Date() > eventDate
            }
        case .Future:
            events = cachedEvents.filter { event in
                guard let eventDate = FormatUtility.convertStringToDate(dateString: event.date) else {return false}
                return Date() < eventDate
            }
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
        applySelectedFilterToSearchedEvents(searchedEvents)
    }
}
