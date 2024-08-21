//
//  EventsViewModel.swift
//  Eventrr
//
//  Created by Dev on 8/9/24.
//

import Foundation

class HomeViewModel {
    
    // MARK: - Public Properties
    
    public var eventsList: [EventModel] = []
    public let categoriesList: [EventCategoryFilter] = EventCategoryFilter.allCases
    
    // MARK: - Public Methods
    
    public func fetchAllEvents() async throws {
        let snapshot = try await FirebaseService.shared.fetchAllData(from: DBCollections.Events.rawValue)
        let documents = snapshot.documents
        
        eventsList = []
        for document in documents {
            let jsonData = try JSONSerialization.data(withJSONObject: document.data(), options: [])
            let event = try JSONDecoder().decode(EventModel.self, from: jsonData)
            eventsList.append(event)
        }
    }
    
    public func fetchEventsAgainstTitle(_ queryString: String) async throws {
        let snapshot = try await FirebaseService.shared.fetchDataContaining(
            queryString: queryString,
            in: DBCollectionFields.Events.title.rawValue,
            from: DBCollections.Events.rawValue
        )
        let documents = snapshot.documents
        
        eventsList = []
        for document in documents {
            let jsonData = try JSONSerialization.data(withJSONObject: document.data(), options: [])
            let event = try JSONDecoder().decode(EventModel.self, from: jsonData)
            eventsList.append(event)
        }
    }
    
    public func fetchEventsAgainstCategory(_ category: String) async throws {
        let snapshot = try await FirebaseService.shared.fetchDataAgainst(
            queryString: category,
            in: DBCollectionFields.Events.category.rawValue,
            from: DBCollections.Events.rawValue
        )
        let documents = snapshot.documents
        
        eventsList = []
        for document in documents {
            let jsonData = try JSONSerialization.data(withJSONObject: document.data(), options: [])
            let event = try JSONDecoder().decode(EventModel.self, from: jsonData)
            eventsList.append(event)
        }
    }
}
