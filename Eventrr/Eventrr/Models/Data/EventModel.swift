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
    
    var attendees: [EventAttendee] = []
    
    init(
        id: String? = nil,
        title: String, category: String, date: String, fromTime: String, toTime: String, description: String,
        locationName: String, latitude: String, longitude: String,
        ownerId: String, ownerName: String
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
    }
    
    /*
     Used while storing the model in firebase as it expects [String: String]
     */
//    func toDictionary() -> [String: String]? {
//        let encoder = JSONEncoder()
//        encoder.outputFormatting = .withoutEscapingSlashes
//        
//        if let data = try? encoder.encode(self) {
//            let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
//            return json?.mapValues { "\($0)" }
//        }
//        return nil
//    }
}
