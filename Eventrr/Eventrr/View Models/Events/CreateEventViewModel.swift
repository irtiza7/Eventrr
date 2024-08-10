//
//  CreateEventViewModel.swift
//  Eventrr
//
//  Created by Dev on 8/9/24.
//

import Foundation
import UIKit

final class CreateEventViewModel {
    
    // MARK: - Public Properties
    
    public let eventCategories = EventCategory.allCases
    public var selectedEventCategory: EventCategory = EventCategory.allCases.first!
    public var selectedLocation: LocationModel?
    
    // MARK: - Data Storage Methods
    
    public func saveEventToFirebase(event: EventModel) async throws {
        guard let eventData = event.toDictionary() else {return}
        try await FirebaseService.shared.save(data: eventData, into: DBCollections.Events.rawValue)
    }
    
    public func saveEventToLocalStorage(event: EventModel) {}
    
    public func saveEventDraftToLocalStorage(event: DraftEventModel) {}
    
    // MARK: - Utility Methods
    
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

