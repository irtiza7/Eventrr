//
//  EventDetailsViewModel.swift
//  Eventrr
//
//  Created by Dev on 8/22/24.
//

import Foundation
import FirebaseFirestore

class EventDetailsViewModel {
    
    static let identifier = String(describing: EventDetailsViewModel.self)
    
    // MARK: - Private Properties
    
    private let userService: UserServiceProtocol
    private let databaseService: FirebaseService
    
    // MARK: - Public Properties
    
    @Published var deletionError: DeleteStatus?
    @Published var joinAndLeaveEventStatus: JoinAndLeaveEventStatus?
    
    public var selectedEvent: EventModel?
    public var hasUserJoinedEvent: Bool = false
    
    // MARK: - Initializers
    
    init(userService: UserServiceProtocol = UserService.shared!,
         databaseService: FirebaseService = FirebaseService.shared) {
        self.userService = userService
        self.databaseService = databaseService
    }
    
    // MARK: - Public Methods
    
    public func joinEvent() {
        guard let eventId = selectedEvent?.id, let attendeeId = userService.user.id else {
            joinAndLeaveEventStatus = .failure(errorMessage: K.StringMessages.somethingWentWrong)
            return
        }
        
        let eventAttendee = EventAttendeeModel(attendeeId: attendeeId)
        
        guard let encodedData = try? Firestore.Encoder().encode(eventAttendee) else {
            joinAndLeaveEventStatus = .failure(errorMessage: K.StringMessages.somethingWentWrong)
            return
        }
        
        Task {
            do {
                try await databaseService.addToArrayField(
                    elementToAdd: encodedData,
                    arrayFieldName: DatabaseTableColumns.Events.attendees.rawValue,
                    recordId: eventId,
                    table: DatabaseTables.Events.rawValue
                )
                joinAndLeaveEventStatus = .joinSuccessful
            } catch {
                print("[\(EventDetailsViewModel.identifier)] - Error: \n\(error)")
                joinAndLeaveEventStatus = .failure(errorMessage: K.StringMessages.somethingWentWrong)
            }
        }
    }
    
    public func leaveEvent() {
        guard let eventId = selectedEvent?.id, let attendeeId = userService.user.id else {
            joinAndLeaveEventStatus = .failure(errorMessage: K.StringMessages.somethingWentWrong)
            return
        }
        
        let eventAttendee = EventAttendeeModel(attendeeId: attendeeId)
        
        guard let encodedData = try? Firestore.Encoder().encode(eventAttendee) else {
            joinAndLeaveEventStatus = .failure(errorMessage: K.StringMessages.somethingWentWrong)
            return
        }
        
        Task {
            do {
                try await databaseService.deleteFromArrayField(
                    elementToDelete: encodedData,
                    arrayFieldName: DatabaseTableColumns.Events.attendees.rawValue,
                    recordId: eventId,
                    table: DatabaseTables.Events.rawValue
                )
                joinAndLeaveEventStatus = .leaveSuccessful
            } catch {
                print("[\(EventDetailsViewModel.identifier)] - Error: \n\(error)")
                joinAndLeaveEventStatus = .failure(errorMessage: K.StringMessages.somethingWentWrong)
            }
        }
    }
    
    public func deleteEvent() {
        Task {
            do {
                guard let id = selectedEvent?.id else {
                    deletionError = .failure(message: K.StringMessages.somethingWentWrong)
                    return
                }
                try await databaseService.delete(recordId: id, table: DatabaseTables.Events.rawValue)
                deletionError = .success
            } catch {
                print("[\(EventDetailsViewModel.identifier)] - Error: \n\(error)")
                deletionError = .failure(message: K.StringMessages.somethingWentWrong)
            }
        }
    }
}

enum DeleteStatus {
    case success, failure(message: String)
}

enum JoinAndLeaveEventStatus {
    case joinSuccessful, leaveSuccessful, failure(errorMessage: String)
}
