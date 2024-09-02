//
//  RepoService.swift
//  Eventrr
//
//  Created by Irtiza on 8/28/24.
//

import Foundation
import RealmSwift
import FirebaseFirestore

/// A singleton service class responsible for managing Realm database operations and synchronizing data with Firestore.
final class RealmService {
    
    static var shared: RealmService?
    
    static func createInstance() {
        if RealmService.shared == nil {
            RealmService.shared = RealmService()
        }
    }
    
    // MARK: - Private Properties
    
    private let realm = try! Realm()
    private let databaseService: FirebaseService
    private var eventListener: ListenerRegistration?
    private var userListener: ListenerRegistration?
    
    // MARK: - Initializers and Deinitializers
    
    private init(databaseService: FirebaseService = FirebaseService.shared) {
        self.databaseService = databaseService
        addListeners()
    }
    
    deinit {
        eventListener?.remove()
        userListener?.remove()
    }
    
    // MARK: - Private Methods
    
    /// Adds a listener to the Firestore collection for real-time updates.
    private func addListeners() {
        eventListener = Firestore.firestore().collection(DatabaseTables.Events.rawValue)
            .addSnapshotListener { [weak self] snapshot, error in
                if let _ = error { return }
                
                guard let documents = snapshot?.documents else {return}
                self?.parseAndSaveEvents(documents: documents)
            }
    }
    
    /// Parses the Firestore documents and updates the Realm database.
    /// - Parameter documents: An array of `QueryDocumentSnapshot` representing the Firestore documents.
    private func parseAndSaveEvents(documents: [QueryDocumentSnapshot]) {
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
                    
                    realm.add(eventRealmModel)
                }
            }
        } catch {
            print(error)
        }
    }
    
    // MARK: - Public Methods
    
    /// Fetches all objects of a specified type from the Realm database.
    /// - Parameter ofType: The type of objects to fetch.
    /// - Returns: A `Results` object containing all fetched objects of the specified type.
    public func fetchAllObjects<T: Object>(ofType: T.Type) -> Results<T> {
        realm.objects(ofType.self)
    }
    
    /// Fetches objects of a specified type from the Realm database where a field matches a given value.
    /// - Parameters:
    ///   - ofType: The type of objects to fetch.
    ///   - field: The field to filter by.
    ///   - value: The value to match in the specified field.
    /// - Returns: A `Results` object containing all fetched objects that match the filter criteria.
    public func fetchObjectsWhere<T: Object>(ofType: T.Type, field: String, equalTo value: String) -> Results<T> {
        realm.objects(ofType.self).filter("\(field) == %@", value)
    }
    
    /// Fetches objects of a specified type from the Realm database where an array subfield matches a given value.
    /// - Parameters:
    ///   - ofType: The type of objects to fetch.
    ///   - arrayField: The name of the array field to filter by.
    ///   - subField: The name of the subfield within the array field.
    ///   - value: The value to match in the specified subfield.
    /// - Returns: A `Results` object containing all fetched objects that match the filter criteria.
    public func fetchObjectsWhereArraySubfield<T: Object>(
        ofType: T.Type,
        arrayField: String,
        subField: String,
        equalTo value: String
    ) -> Results<T> {
        let predicate = NSPredicate(format: "ANY \(arrayField).\(subField) == %@", value)
        return realm.objects(ofType.self).filter(predicate)
    }
    
    public func deleteAllObjects<T: Object>(ofType: T.Type) {
        do {
            try realm.write {
                realm.delete(realm.objects(ofType.self))
            }
        } catch {
            print(error)
        }
    }
    
    public func saveUserDataToLocalStorage(user: UserModel) {
        print(user)
        do {
            try realm.write {
                realm.delete(realm.objects(UserRealmModel.self))
                
                let userRealmModel = UserRealmModel()
                userRealmModel.id = user.id!
                userRealmModel.authId = user.authId
                userRealmModel.email = user.email
                userRealmModel.name = user.name!
                userRealmModel.role = user.role!.rawValue
                
                realm.add(userRealmModel)
            }
        } catch {
            print(error)
        }
    }
}
