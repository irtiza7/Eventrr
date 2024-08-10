//
//  UserRole.swift
//  Eventrr
//
//  Created by Dev on 8/12/24.
//

import Foundation

enum UserRole: String, CaseIterable, Decodable {
    case Admin, Attendee
    
    init?(rawValue: String) {
        switch rawValue {
        case UserRole.Admin.rawValue:
            self = .Admin
        case UserRole.Attendee.rawValue:
            self = .Attendee
        default:
            return nil
        }
    }
}
