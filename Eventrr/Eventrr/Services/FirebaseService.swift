//
//  FirebaseService.swift
//  Eventrr
//
//  Created by Dev on 7/30/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

final class FirebaseService {
    
    static let shared = FirebaseService()
    
    private init() {}
    
    // MARK: - Auth Network Calls
    
    public func login(email: String, password: String) async throws -> AuthDataResult {
        return try await withCheckedThrowingContinuation { continuation in
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if let error { continuation.resume(throwing: error) }
                if let authResult { continuation.resume(returning: authResult) }
            }
        }
    }
    
    public func signup(email: String, password: String) async throws -> AuthDataResult {
        return try await withCheckedThrowingContinuation { continuation in
            Auth.auth().createUser(withEmail: email, password: password) { result, error in
                if let error { continuation.resume(throwing: error) }
                if let result { continuation.resume(returning: result) }
            }
        }
    }
    
    public func sendPasswordResetEmail(email: String) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            Auth.auth().sendPasswordReset(withEmail: email) { error in
                if let error { 
                    continuation.resume(throwing: error)
                    return
                }
                continuation.resume()
            }
        }
    }
    
    public func reauthenticateUser(credential: AuthCredential) async throws {
        return try await withCheckedThrowingContinuation() { continuation in
            guard let _ = Auth.auth().currentUser else {
                continuation.resume(throwing: AuthError.userNotAuthenticated)
                return
            }
            
            Auth.auth().currentUser?.reauthenticate(with: credential) { (authResult, error) in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                continuation.resume()
            }
        }
    }
    
    public func updatePassword(password: String) async throws {
        return try await withCheckedThrowingContinuation() {continuation in
            guard let _ = Auth.auth().currentUser else {
                continuation.resume(throwing: AuthError.userNotAuthenticated)
                return
            }
            
            Auth.auth().currentUser?.updatePassword(to: password) { error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                continuation.resume()
            }
        }
    }
    
    // MARK: - Data Network Calls
    
    public func create(data: [String: Any], table: String) async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            let docRef = Firestore.firestore().collection(table).document()
            
            var dataCopy = data
            dataCopy[DatabaseTableColumns.Users.id.rawValue] = docRef.documentID
            
            docRef.setData(dataCopy) { error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                continuation.resume(returning: docRef.documentID)
            }
        }
    }
    
    public func create(data: [String: Any], tableId: String, table: String) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            Firestore.firestore().collection(table).document(tableId).setData(data) { error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                continuation.resume()
            }
        }
    }
    
    public func update(data: [String: Any], recordId: String, table:  String) async throws {
        return try await withCheckedThrowingContinuation {continuation in
            let docRef = Firestore.firestore().collection(table).document(recordId)
            
            docRef.updateData(data) { error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                continuation.resume()
            }
        }
    }
    
    public func addToArrayField(
        elementToAdd: [String: Any],
        arrayFieldName: String,
        recordId: String,
        table: String
    ) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            let docRef = Firestore.firestore().collection(table).document(recordId)
            docRef.updateData([arrayFieldName: FieldValue.arrayUnion([elementToAdd])]) { error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                continuation.resume()
            }
        }
    }
    
    public func deleteFromArrayField(
        elementToAdd: [String: Any],
        arrayFieldName: String,
        recordId: String,
        table: String
    ) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            let docRef = Firestore.firestore().collection(table).document(recordId)
            docRef.updateData([arrayFieldName: FieldValue.arrayRemove([elementToAdd])]) { error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                continuation.resume()
            }
        }
    }
    
    public func delete(recordId: String, table: String) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            Firestore.firestore().collection(table).document(recordId).delete() { error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                continuation.resume()
            }
        }
    }
    
    public func fetchAgainstArrayField(
        containingData: [String: Any],
        arrayFieldName: String,
        table: String
    ) async throws -> QuerySnapshot {
        let query = Firestore.firestore().collection(table).whereField(arrayFieldName, arrayContains: containingData)
        return try await query.getDocuments()
    }
    
    public func fetchAllData(table: String) async throws -> QuerySnapshot {
        return try await Firestore.firestore().collection(table)
            .order(by: DatabaseTableColumns.Events.date.rawValue, descending: false)
            .getDocuments()
    }
    
    public func fetchDataAgainstId(_ id: String, table: String) async throws -> QuerySnapshot {
        return try await Firestore.firestore().collection(table)
            .whereField(DatabaseTableColumns.Users.id.rawValue, isEqualTo: id)
            .getDocuments()
    }
    
    public func fetchDataMatching(value: String, column: String, table: String) async throws -> QuerySnapshot {
        return try await Firestore.firestore().collection(table)
            .whereField(column, isGreaterThanOrEqualTo: value)
            .getDocuments()
    }
    
    public func fetchDataAgainst(value: String, column: String, table: String) async throws -> QuerySnapshot {
        return try await Firestore.firestore().collection(table)
            .whereField(column, isEqualTo: value)
            .getDocuments()
    }
    
    // MARK: - Error Handling
    
    public func parseCredentialsNoLongerValiedError(_ error: NSError) -> (message: String, code: Int)? {
        if error.code == 17021 {
            return (message: "Credentials updated, please login agaion.", code: error.code)
        }
        return nil
    }
    
    public func parseNetworkError(_ error: NSError) -> (message: String, code: Int)? {
        if error.code == 1009 || error.code == -1009 || error.code == 17020 {
            return (message: "You seem to be offline, check internet connection.", code: error.code)
        }
        return nil
    }
    
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
