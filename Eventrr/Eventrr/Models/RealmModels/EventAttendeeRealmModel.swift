//
//  EventAttendeeRealmModel.swift
//  Eventrr
//
//  Created by Irtiza on 8/28/24.
//

import Foundation
import RealmSwift

class EventAttendeeRealmModel: Object {
    @Persisted var attendeeId: String = ""
}
