//
//  FirebaseModelConstants.swift
//  Eventrr
//
//  Created by Dev on 8/8/24.
//

import Foundation

enum DBCollections: String {
    case users
}

struct DBCollectionFields {
    enum Users: String {
        case id, email, name, type
    }
}
