//
//  EventsModel.swift
//  Eventrr
//
//  Created by Dev on 8/9/24.
//

import Foundation

struct EventModel: Codable {
    let id: String?
    let title: String
    let category: String
    let date: String
    let fromTime: String
    let toTime: String
    let description: String
    
    let locationName: String
    let latitude: String
    let longitude: String
    
    let ownerId: String
    let ownerName: String
    
    var attendees: [EventAttendeeModel] = []
    
    init(
        id: String? = nil,
        title: String, category: String, date: String, fromTime: String, toTime: String, description: String,
        locationName: String, latitude: String, longitude: String,
        ownerId: String, ownerName: String,
        attendees: [EventAttendeeModel] = []
    ) {
        self.id = id
        self.title = title
        self.category = category
        self.date = date
        self.fromTime = fromTime
        self.toTime = toTime
        self.description = description
        self.locationName = locationName
        self.latitude = latitude
        self.longitude = longitude
        self.ownerId = ownerId
        self.ownerName = ownerName
        self.attendees = attendees
    }
}
