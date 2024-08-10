//
//  EventDetailsView.swift
//  Eventrr
//
//  Created by Dev on 8/20/24.
//

import SwiftUI
import CoreLocation
import MapKit

struct EventDetailsView: View {
    let event = EventModel(
        id: "1",
        title: "Event Title",
        category: "Concert",
        date: "2024-08-19",
        fromTime: "17:00",
        toTime: "19:00",
        description: "ascsd",
        locationName: "Location Name",
        latitude: "37.7749",
        longitude: "-122.4194",
        ownerId: "asds",
        ownerName: "John Doe"
    )
    
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(event.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                HStack {
                    Image(systemName: "calendar")
                    Text(event.date)
                }
                
                HStack {
                    Image(systemName: "clock")
                    Text("\(event.fromTime) - \(event.toTime)")
                }
                
                HStack {
                    Image(systemName: "location")
                    Text(event.locationName)
                }
                
//                Map(coordinateRegion: .constant(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: event.latitude as! Double, longitude: event.longitude as! Double), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))))
//                    .frame(height: 200)
//                    .cornerRadius(10)
                
                HStack {
                    Image(systemName: "person.circle")
                    Text("Owner: \(event.ownerName)")
                }
                
                HStack {
                    Image(systemName: "person.3")
                    Text("Number of Attendees: \(50)")
                }
                
                HStack {
                    Image(systemName: "tag")
                    Text("Category: \(event.category)")
                }
                
                Text("Description")
                    .font(.headline)
                Text(event.description)
                    .padding(.top, 4)
            }
            .padding()
        }
        .navigationTitle("Event Details")
    }
    
    
    private func formattedDate(_ date: String) -> String {
        // Custom date formatting logic here
        return date
    }
    
    // Helper function to format the time
    private func formattedTime(_ time: String) -> String {
        // Custom time formatting logic here
        return time
    }
}

struct MapView: UIViewRepresentable {
    var coordinate: CLLocationCoordinate2D
    
    func makeUIView(context: Context) -> MKMapView {
        MKMapView(frame: .zero)
    }
    
    func updateUIView(_ view: MKMapView, context: Context) {
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        view.setRegion(region, animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        view.addAnnotation(annotation)
    }
}

struct EventDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        EventDetailsView()
    }
}

