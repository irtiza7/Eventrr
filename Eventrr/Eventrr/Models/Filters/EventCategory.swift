//
//  EventCategory.swift
//  Eventrr
//
//  Created by Dev on 8/16/24.
//

import Foundation

enum EventCategory: String, CaseIterable {
    case Conference, Concert, Sport, Festival, Community, Academic
}

enum EventCategoryFilter: String, CaseIterable {
    case All, Conference, Concert, Sport, Festival, Community, Academic
}
