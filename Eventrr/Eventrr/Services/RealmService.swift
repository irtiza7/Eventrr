//
//  RepoService.swift
//  Eventrr
//
//  Created by Irtiza on 8/28/24.
//

import Foundation
import RealmSwift
import FirebaseFirestore

class RealmService {
    
    static var shared: RealmService?
    
    static func createInstance() {
        if RealmService.shared == nil {
            RealmService.shared = RealmService()
        }
    }
    
    // MARK: - Private Properties
    
    private let realm = try! Realm()
    private let databaseService: FirebaseService
    private var listener: ListenerRegistration?
    
    // MARK: - Initializers and Deinitializers
    
    private init(databaseService: FirebaseService = FirebaseService.shared) {
        self.databaseService = databaseService
        addListeners()
    }
    
    deinit {
        listener?.remove()
    }
    
    // MARK: - Private Methods
    
    func addListeners() {
        listener = Firestore.firestore().collection(DatabaseTables.Events.rawValue)
            .addSnapshotListener { [weak self] snapshot, error in
                if let _ = error { return }
                
                guard let documents = snapshot?.documents else {return}
                self?.parseEvents(documents: documents)
            }
    }
    
    private func parseEvents(documents: [QueryDocumentSnapshot]) {
        do {
            try realm.write {
                realm.delete(realm.objects(EventRealmModel.self))
                
                for document in documents {
                    guard let decodedEvent = try? document.data(as: EventModel.self) else {return}
                    
                    let eventRealmModel = EventRealmModel()
                    
                    eventRealmModel.id = decodedEvent.id!
                    eventRealmModel.title = decodedEvent.title
                    eventRealmModel.category = decodedEvent.category
                    
                    eventRealmModel.date = FormatUtility.convertStringToDateUTC(dateString: decodedEvent.date)!
                    eventRealmModel.fromTime = FormatUtility.convertStringToDateUTC(dateString: decodedEvent.fromTime)!
                    eventRealmModel.toTime = FormatUtility.convertStringToDateUTC(dateString: decodedEvent.toTime)!
                    
                    eventRealmModel.eventDescription = decodedEvent.description
                    
                    eventRealmModel.locationName = decodedEvent.locationName
                    eventRealmModel.latitude = Double(decodedEvent.latitude) ?? 0.0
                    eventRealmModel.longitude = Double(decodedEvent.longitude) ?? 0.0
                    
                    eventRealmModel.ownerId = decodedEvent.ownerId
                    eventRealmModel.ownerName = decodedEvent.ownerName
                    
                    for attendee in decodedEvent.attendees {
                        let realmAttendee = EventAttendeeRealmModel()
                        realmAttendee.attendeeId = attendee.attendeeId
                        
                        eventRealmModel.attendees.append(realmAttendee)
                    }
                    realm.add(eventRealmModel, update: .modified)
                }
            }
        } catch {
            print(error)
        }
    }
    
    // MARK: - Public Methods
    
    public func fetchAllObjects<T: Object>(ofType: T.Type) -> Results<T> {
        realm.objects(ofType.self)
    }
    
    public func fetchObjectsWhere<T: Object>(ofType: T.Type, field: String, equalTo value: String) -> Results<T> {
        realm.objects(ofType.self).filter("\(field) == %@", value)
    }
    
    public func fetchObjectsWhereArraySubfield<T: Object>(
        ofType: T.Type,
        arrayField: String,
        subField: String,
        equalTo value: String
    ) -> Results<T> {
        let predicate = NSPredicate(format: "ANY \(arrayField).\(subField) == %@", value)
        return realm.objects(ofType.self).filter(predicate)
    }
}
