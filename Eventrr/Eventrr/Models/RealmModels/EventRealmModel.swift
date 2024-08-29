//
//  EventRealmModel.swift
//  Eventrr
//
//  Created by Irtiza on 8/28/24.
//

import Foundation
import RealmSwift

class EventRealmModel: Object {
    @Persisted(primaryKey: true) var id: String = ""
    @Persisted var title: String = ""
    @Persisted var category: String = ""
    
    @Persisted var date: Date = Date()
    @Persisted var fromTime: Date = Date()
    @Persisted var toTime: Date = Date()
    
    @Persisted var eventDescription: String = ""
    
    @Persisted var locationName: String = ""
    @Persisted var latitude: Double = 0.0
    @Persisted var longitude: Double = 0.0
    
    @Persisted var ownerId: String = ""
    @Persisted var ownerName: String = ""
    
    @Persisted var attendees = List<EventAttendeeRealmModel>()
}
