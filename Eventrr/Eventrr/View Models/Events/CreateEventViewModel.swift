//
//  CreateEventViewModel.swift
//  Eventrr
//
//  Created by Dev on 8/9/24.
//

import Foundation
import UIKit
import FirebaseFirestore

final class CreateEventViewModel {
    
    static let identifier = String(describing: CreateEventViewModel.self)
    
    // MARK: - Private Properties
    
    private let userService: UserServiceProtocol
    private let databaseService: FirebaseService
    
    // MARK: - Public Properties
    
    @Published public var eventCreateAndUpdateStatus: EventCreateAndUpdateStatus?
    @Published public var event: EventModel?
    
    public let eventCategories = EventCategory.allCases
    
    public var eventToEdit: EventModel?
    public var selectedEventCategory: EventCategory = EventCategory.allCases.first!
    public var selectedLocation: LocationModel?
    
    // MARK: - Initializers
    
    init(userService: UserServiceProtocol = UserService.shared!,
         databaseService: FirebaseService = FirebaseService.shared) {
        self.userService = userService
        self.databaseService = databaseService
    }
    
    // MARK: - Public Methods
    
    public func createEvent() {
        guard let event, let encodedEvent = try? Firestore.Encoder().encode(event) else {
            eventCreateAndUpdateStatus = .failure(errorMessage: K.StringMessages.somethingWentWrong)
            return
        }
        
        Task {
            do {
                let _ = try await databaseService.create(data: encodedEvent, table: DatabaseTables.Events.rawValue)
                eventCreateAndUpdateStatus = .success
            } catch {
                print("[\(CreateEventViewModel.identifier)] - Error: \n\(error)")
                
                if let parsedError = FirebaseService.shared.parseNetworkError(error as NSError) {
                    eventCreateAndUpdateStatus = .failure(errorMessage: parsedError.message)
                } else {
                    eventCreateAndUpdateStatus = .failure(errorMessage: K.StringMessages.somethingWentWrong)
                }
            }
        }
    }
    
    public func updateEvent() {
        guard let event, let id = event.id, let encodedEvent = try? Firestore.Encoder().encode(event) else {
            eventCreateAndUpdateStatus = .failure(errorMessage: K.StringMessages.somethingWentWrong)
            return
        }
        
        Task {
            do {
                try await databaseService.update(data: encodedEvent, recordId: id, table: DatabaseTables.Events.rawValue)
                eventCreateAndUpdateStatus = .success
            } catch {
                print("[\(CreateEventViewModel.identifier)] - Error: \n\(error)")
                
                if let parsedError = FirebaseService.shared.parseNetworkError(error as NSError) {
                    eventCreateAndUpdateStatus = .failure(errorMessage: parsedError.message)
                } else {
                    eventCreateAndUpdateStatus = .failure(errorMessage: K.StringMessages.somethingWentWrong)
                }
            }
        }
    }
    
    public func validateDateAndTime(
        selectedDate: Date,
        fromTime: Date,
        toTime: Date) -> String? {
            
            let calendar = Calendar.current
            let todayDate = Date()
            
            let fromDateAndTime = calendar.date(
                bySettingHour: calendar.component(.hour, from: fromTime),
                minute: calendar.component(.minute, from: fromTime),
                second: 0,
                of: selectedDate
            )!
            
            let toDateAndTime = calendar.date(
                bySettingHour: calendar.component(.hour, from: toTime),
                minute: calendar.component(.minute, from: toTime),
                second: 0,
                of: selectedDate
            )!
            
            if calendar.isDateInToday(selectedDate) {
                let oneHourLater = calendar.date(byAdding: .hour, value: 1, to: todayDate)!
                
                if fromDateAndTime < oneHourLater {
                    return K.StringMessages.startTimeOneHourAfterCurrentTime
                }
                
                let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: selectedDate)!
                
                if toDateAndTime > endOfDay {
                    return K.StringMessages.endTimeBeforeDayEndTime
                }
            }
            
            if fromDateAndTime >= toDateAndTime {
                return K.StringMessages.startTimeMustPrecedeEndTime
            }
            return nil
        }
}

enum EventCreateAndUpdateStatus {
    case success, failure(errorMessage: String)
}
