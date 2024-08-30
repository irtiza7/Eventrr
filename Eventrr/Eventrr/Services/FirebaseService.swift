//
//  FirebaseService.swift
//  Eventrr
//
//  Created by Dev on 7/30/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

/// A service class that manages interactions with Firebase Firestore, including saving, updating, deleting, and fetching documents.
/// > Important: Requires Firebase SDK to be installed and GoogleService-Info.plist file to be present in the project.
final class FirebaseService {
    
    static let shared = FirebaseService()
    
    private init() {}
    
    // MARK: - Auth Network Calls
    
    /// Logins the user, using Firebase Authentication.
    /// - Parameters:
    ///   - email: Email with which the user has signed in.
    ///   - password: Password with which the user has signed in.
    /// - Returns: Returns  an AuthDataResult, which contains  the result of a successful sign-in, link and reauthenticate action.
    public func login(email: String, password: String) async throws -> AuthDataResult {
        return try await withCheckedThrowingContinuation { continuation in
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if let error { continuation.resume(throwing: error) }
                if let authResult { continuation.resume(returning: authResult) }
            }
        }
    }
    
    /// Signups a user, using Firebase Authentication.
    /// - Parameters:
    ///   - email: Email with which user wants to signup.
    ///   - password: Password with which user wants to signup.
    /// - Returns: Returns  an AuthDataResult, which contains  the result of a successful sign-in, link and reauthenticate action.
    public func signup(email: String, password: String) async throws -> AuthDataResult {
        return try await withCheckedThrowingContinuation { continuation in
            Auth.auth().createUser(withEmail: email, password: password) { result, error in
                if let error { continuation.resume(throwing: error) }
                if let result { continuation.resume(returning: result) }
            }
        }
    }
    
    /// Sends a password reset email, using Firebase Authentication.
    /// - Parameter email: Email to which the password reset link should be sent.
    public func sendPasswordResetEmail(email: String) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            Auth.auth().sendPasswordReset(withEmail: email) { error in
                if let error { continuation.resume(throwing: error); return }
                continuation.resume()
            }
        }
    }
    
    /// Reauthenticates the user with provided credentials (Firebase AuthCredentials) to refresh the authentication token.
    /// Throws a Firebase UserNotAuthenticated error if the provided credentials are invalid.
    /// - Parameter credential: Credentials against which the authentication has to be refreshed.
    public func reauthenticateUser(credential: AuthCredential) async throws {
        return try await withCheckedThrowingContinuation() { continuation in
            guard let _ = Auth.auth().currentUser else {
                continuation.resume(throwing: AuthError.userNotAuthenticated)
                return
            }
            Auth.auth().currentUser?.reauthenticate(with: credential) { (authResult, error) in
                if let error { continuation.resume(throwing: error); return }
                continuation.resume()
            }
        }
    }
    
    /// Updates the current password with the provided one, for current logged in user..
    /// - Parameter password: Password that has to be set as new one.
    public func updatePassword(password: String) async throws {
        return try await withCheckedThrowingContinuation() {continuation in
            guard let _ = Auth.auth().currentUser else {
                continuation.resume(throwing: AuthError.userNotAuthenticated)
                return
            }
            Auth.auth().currentUser?.updatePassword(to: password) { error in
                if let error { continuation.resume(throwing: error); return }
                continuation.resume()
            }
        }
    }
    
    // MARK: - Data Network Calls
    
    /// Creates a record in the mentioned Firestore table with given data.
    /// Also automatically inserts the generated Id into the table, as 'id' field.
    /// - Parameters:
    ///   - data: Data to be inserted in the newly created record.
    ///   - table: Table/collection where the new record should be created.
    /// - Returns: Returns the generated id of newly created record.
    public func create(data: [String: Any], table: String) async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            let docRef = Firestore.firestore().collection(table).document()
            
            var mutableDataCopy = data
            mutableDataCopy[DatabaseTableColumns.Users.id.rawValue] = docRef.documentID
            
            docRef.setData(mutableDataCopy) { error in
                if let error { continuation.resume(throwing: error); return }
                continuation.resume(returning: docRef.documentID)
            }
        }
    }
    
    /// Updates the record in Firestore collection.
    /// - Parameters:
    ///   - data: Record's data with which the old one will be updated.
    ///   - recordId: Id of record whose data is to be updated.
    ///   - table: Table in which the update operation will be performed.
    public func update(data: [String: Any], recordId: String, table:  String) async throws {
        return try await withCheckedThrowingContinuation {continuation in
            let docRef = Firestore.firestore().collection(table).document(recordId)
            docRef.updateData(data) { error in
                    if let error { continuation.resume(throwing: error); return }
                    continuation.resume()
                }
        }
    }
    
    /// Batched writes based method to rename owner's name of an event.
    ///
    /// Fetches the documents containing the given owner ID. Loops through these documents and adds a batch write
    /// updating the field with provided value.
    ///
    /// ```
    /// let batch = Firestore.firestore().batch()
    /// for document in documents {
    ///     let documentRef = eventsRef.document(document.documentID)
    ///     batch.updateData([
    ///         DatabaseTableColumns.Events.ownerName.rawValue: newName
    ///         ], forDocument: documentRef)
    /// }
    /// ```
    /// - Parameters:
    ///   - ownerId: Owner's id to filter out events against. The updating write operation will be applied on these events only.
    ///   - newName: New name of the owner which will be inserted in place of the old one.
    public func updateOwnerNameInEvents(ownerId: String, newName: String) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            let eventsRef = Firestore.firestore().collection(DatabaseTables.Events.rawValue)
            eventsRef
                .whereField(DatabaseTableColumns.Events.ownerId.rawValue, isEqualTo: ownerId)
                .getDocuments { snapshot, error in
                    if let error { continuation.resume(throwing: error); return }
                    guard let documents = snapshot?.documents else { continuation.resume(); return }
                    
                    let batch = Firestore.firestore().batch()
                    for document in documents {
                        let documentRef = eventsRef.document(document.documentID)
                        batch
                            .updateData(
                                [DatabaseTableColumns.Events.ownerName.rawValue: newName],
                                forDocument: documentRef
                            )
                    }
                    batch.commit { error in
                        if let error { continuation.resume(throwing: error); return }
                        continuation.resume()
                    }
                }
        }
    }
    
    /// Adds data into an array field of the record.
    /// - Parameters:
    ///   - elementToAdd: Array element/data to add. The data will be an object/dictionary.
    ///   - arrayFieldName: Name of the array field where the insertion is to be done.
    ///   - recordId: Id of the record in which the array element insertion will be performed.
    ///   - table: Name of the table/collection where the record exists in which the insertion is to be done.
    public func addToArrayField(
        elementToAdd: [String: Any],
        arrayFieldName: String,
        recordId: String,
        table: String
    ) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            let docRef = Firestore.firestore().collection(table).document(recordId)
            docRef.updateData([arrayFieldName: FieldValue.arrayUnion([elementToAdd])]) { error in
                if let error { continuation.resume(throwing: error); return }
                continuation.resume()
            }
        }
    }
    
    /// Deletes an element from an array field of the record.
    /// - Parameters:
    ///   - elementToDelete: Array element/data to remove. The data should be an object/dictionary.
    ///   - arrayFieldName: Name of the array field from which the element is to be removed.
    ///   - recordId: Id of the record in which the array element deletion will be performed.
    ///   - table: Name of the table/collection where the record exists.
    public func deleteFromArrayField(
        elementToDelete: [String: Any],
        arrayFieldName: String,
        recordId: String,
        table: String
    ) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            let docRef = Firestore.firestore().collection(table).document(recordId)
            docRef.updateData([arrayFieldName: FieldValue.arrayRemove([elementToDelete])]) { error in
                if let error { continuation.resume(throwing: error); return }
                continuation.resume()
            }
        }
    }
    
    /// Deletes a record from the specified Firestore table.
    /// - Parameters:
    ///   - recordId: Id of the record to be deleted.
    ///   - table: Name of the table/collection where the record exists.
    public func delete(recordId: String, table: String) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            Firestore.firestore().collection(table).document(recordId).delete() { error in
                if let error { continuation.resume(throwing: error); return }
                continuation.resume()
            }
        }
    }
    
    /// Fetches documents from a collection where an array field contains a specific element.
    /// - Parameters:
    ///   - containingData: The data element that should be contained in the array field.
    ///   - arrayFieldName: The name of the array field to search.
    ///   - table: The name of the table/collection to search in.
    /// - Returns: Returns a QuerySnapshot containing the documents that match the criteria.
    public func fetchAgainstArrayField(containingData: [String: Any], arrayFieldName: String, table: String)
    async throws -> QuerySnapshot {
        let query = Firestore.firestore().collection(table).whereField(arrayFieldName, arrayContains: containingData)
        return try await query.getDocuments()
    }
    
    /// Fetches all documents from a specified Firestore collection, ordered by date in ascending order.
    /// - Parameter table: The name of the table/collection to fetch data from.
    /// - Returns: Returns a QuerySnapshot containing all documents from the collection.
    public func fetchAllData(table: String) async throws -> QuerySnapshot {
        return try await Firestore.firestore().collection(table)
            .order(by: DatabaseTableColumns.Events.date.rawValue, descending: false)
            .getDocuments()
    }
    
    /// Fetches documents from a Firestore collection where a specific field matches a given ID.
    /// - Parameters:
    ///   - id: The ID value to match.
    ///   - table: The name of the table/collection to search in.
    /// - Returns: Returns a QuerySnapshot containing the documents that match the criteria.
    public func fetchDataAgainstId(_ id: String, table: String) async throws -> QuerySnapshot {
        return try await Firestore.firestore().collection(table)
            .whereField(DatabaseTableColumns.Users.id.rawValue, isEqualTo: id)
            .getDocuments()
    }
    
    /// Fetches documents from a Firestore collection where a specific field's value is greater than or equal to a given value.
    /// - Parameters:
    ///   - value: The value to match or exceed.
    ///   - column: The name of the field/column to search in.
    ///   - table: The name of the table/collection to search in.
    /// - Returns: Returns a QuerySnapshot containing the documents that match the criteria.
    public func fetchDataMatching(value: String, column: String, table: String) async throws -> QuerySnapshot {
        return try await Firestore.firestore().collection(table)
            .whereField(column, isGreaterThanOrEqualTo: value)
            .getDocuments()
    }
    
    /// Fetches documents from a Firestore collection where a specific field matches a given value.
    /// - Parameters:
    ///   - value: The value to match.
    ///   - column: The name of the field/column to search in.
    ///   - table: The name of the table/collection to search in.
    /// - Returns: Returns a QuerySnapshot containing the documents that match the criteria.
    public func fetchDataAgainst(value: String, column: String, table: String) async throws -> QuerySnapshot {
        return try await Firestore.firestore().collection(table)
            .whereField(column, isEqualTo: value)
            .getDocuments()
    }
    
    // MARK: - Error Handling
    
    /// Parses the error related to credentials that are no longer valid.
    /// - Parameter error: The NSError to be parsed.
    /// - Returns: Returns a tuple containing an error message and code if the credentials are no longer valid, otherwise returns nil.
    public func parseCredentialsNoLongerValiedError(_ error: NSError) -> (message: String, code: Int)? {
        if error.code == 17021 {
            return (message: "Credentials updated, please login agaion.", code: error.code)
        }
        return nil
    }
    
    /// Parses network-related errors that may occur during Firebase operations.
    /// - Parameter error: The NSError to be parsed.
    /// - Returns: Returns a tuple containing an error message and code if the error is network-related, otherwise returns nil.
    public func parseNetworkError(_ error: NSError) -> (message: String, code: Int)? {
        if error.code == 1009 || error.code == -1009 || error.code == 17020 {
            return (message: "You seem to be offline, check internet connection.", code: error.code)
        }
        return nil
    }
    
    /// Parses login-related errors, including invalid credentials and network issues.
    /// - Parameter error: The NSError to be parsed.
    /// - Returns: Returns a tuple containing an error message and code if a login error is detected, otherwise returns nil.
    public func parseLoginError(_ error: NSError) -> (message: String, code: Int)? {
        if let parsedError = self.parseNetworkError(error) {
            return parsedError
        }
        
        if error.code == 17004 {
            return ("You have entered invalid or old credentials, try again.", 17004)
        }
        
        if let underlyingError = error.userInfo[NSUnderlyingErrorKey] as? NSError {
            if let underlyingError2 = underlyingError.userInfo[NSUnderlyingErrorKey] as? NSError,
               let data = underlyingError2.userInfo["data"] as? Data {
                do {
                    guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {return nil}
                    guard let errorDetails = json["error"] as? [String: Any] else {return nil}
                    
                    guard let message = errorDetails["message"] as? String,
                          let code = errorDetails["code"] as? Int else {return nil}
                    
                    if code == 400 {
                        return ("Invalid Login Credentials", 400)
                    }
                    
                    return (message, code)
                } catch {
                    print("Failed to parse JSON data: \(error.localizedDescription)")
                    return nil
                }
            }
        }
        return nil
    }
    
    /// Parses signup-related errors, including email already in use and network issues.
    /// - Parameter error: The NSError to be parsed.
    /// - Returns: Returns a tuple containing an error message and code if a signup error is detected, otherwise returns nil.
    public func parseSignupError(_ error: NSError) -> (message: String, code: Int)? {
        if let parsedError = self.parseNetworkError(error) {
            return parsedError
        }
        
        if let errorCode = AuthErrorCode(rawValue: error.code) {
            switch errorCode {
            case .emailAlreadyInUse:
                return ("Email address already in use by another account.", error.code)
            default:
                return (error.localizedDescription, error.code)
            }
        }
        return nil
    }
}
