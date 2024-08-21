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
    
    private let db = Firestore.firestore()
    
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
                if let error { continuation.resume(throwing: error) }
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
    
    public func saveUser(data: [String: String], into collection: String) async throws {
        return try await withCheckedThrowingContinuation() { continuation in
            db.collection(collection).addDocument(data: data) { error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                continuation.resume()
            }
        }
    }
    
    public func save(data: [String: String], into collection: String) async throws {
        return try await withCheckedThrowingContinuation() { continuation in
            let docRef = db.collection(collection).document()
            var dataCopy = data
            dataCopy[DBCollectionFields.Users.id.rawValue] = docRef.documentID
            
            db.collection(collection).addDocument(data: dataCopy) { error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                continuation.resume()
            }
        }
    }
    
    public func updateFields(data: [String: String], inDocument documentID: String, into collection:  String) async throws {
        return try await withCheckedThrowingContinuation() {continuation in
            let docRef = db.collection(collection).document(documentID)
            docRef.updateData(data) { error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                continuation.resume()
            }
        }
    }
    
    // TODO: - Update UserModel; Define authId and use save() to automatically store document id
    // TODO: - Update updateUserDocument() logic to use single API call
    
    public func updateUserDocument(data: [String: Any], collection: String, authID: String) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            let query = db.collection(collection).whereField(DBCollectionFields.Users.id.rawValue, isEqualTo: authID)
            
            query.getDocuments { snapshot, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let document = snapshot?.documents.first else {
                    continuation.resume(throwing: NSError(domain: "Firestore", code: 404, userInfo: [NSLocalizedDescriptionKey: "No document found with authID \(authID)"]))
                    return
                }
                
                let documentRef = document.reference
                documentRef.updateData(data) { error in
                    if let error = error {
                        continuation.resume(throwing: error)
                        return
                    }
                    continuation.resume()
                }
            }
        }
    }
    
    public func fetchAllData(from collection: String) async throws -> QuerySnapshot {
        return try await db.collection(collection)
            .order(by: DBCollectionFields.Events.date.rawValue, descending: true)
            .getDocuments()
    }
    
    public func fetchDataAgainstId(_ id: String, from collection: String) async throws -> QuerySnapshot {
        return try await db.collection(collection)
            .whereField(DBCollectionFields.Users.id.rawValue, isEqualTo: id)
            .getDocuments()
    }
    
    public func fetchDataContaining(queryString: String, in document: String, from collection: String) async throws -> QuerySnapshot {
        return try await db.collection(collection)
            .whereField(document, isGreaterThanOrEqualTo: queryString)
            .getDocuments()
    }
    
    public func fetchDataAgainst(queryString: String, in document: String, from collection: String) async throws -> QuerySnapshot {
        return try await db.collection(collection)
            .whereField(document, isEqualTo: queryString)
            .getDocuments()
    }
    
    // MARK: - Error Handling
    
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
            return ("You have entered old credentials, try again.", 17004)
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
