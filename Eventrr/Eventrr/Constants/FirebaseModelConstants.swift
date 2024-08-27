//
//  FirebaseModelConstants.swift
//  Eventrr
//
//  Created by Dev on 8/8/24.
//

import Foundation

enum DatabaseTables: String {
    case Users, Events, EventAttendees
}

struct DatabaseTableColumns {
    enum Users: String {
        case id, authId, email, name, type
    }
    
    enum Events: String {
        case id, title, category, date, fromTime, toTime, description
        case locationName, latitude, longitude
        case ownerName, ownerId
        case attendees
    }
    
    enum EventAttendees: String {
        case attendeeId
    }
}
