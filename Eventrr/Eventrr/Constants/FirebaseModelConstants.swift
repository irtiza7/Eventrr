//
//  FirebaseModelConstants.swift
//  Eventrr
//
//  Created by Dev on 8/8/24.
//

import Foundation

enum DBCollections: String {
    case Users, Events
}

struct DBCollectionFields {
    enum Users: String {
        case id, email, name, type
    }
    
    enum Events: String {
        case id, title, category, date, fromTime, toTime, description
        case locationName, latitude, longitude
        case ownerName, ownerId
    }
}
