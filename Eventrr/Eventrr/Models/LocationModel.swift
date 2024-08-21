//
//  LocationModel.swift
//  Eventrr
//
//  Created by Dev on 8/14/24.
//

import MapKit

struct LocationModel: Codable {
    let name: String
    let latitude: Double
    let longitude: Double
    
    init(name: String, placemark: MKPlacemark) {
        self.name = name
        self.latitude = placemark.coordinate.latitude
        self.longitude = placemark.coordinate.longitude
    }
    
    init(name: String, coordinates: CLLocationCoordinate2D) {
        self.name = name
        self.latitude = coordinates.latitude
        self.longitude = coordinates.longitude
    }
}

