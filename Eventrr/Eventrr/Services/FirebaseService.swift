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
    
    // MARK: - Static Properties
    
    static let shared = FirebaseService()
    
    // MARK: - Private Properties
    
    private let db = Firestore.firestore()
    
    // MARK: - Initializers
    
    private init() {}
    
    // MARK: - Public Methods
    
    public func login(email: String, password: String) async throws -> AuthDataResult {
        return try await withCheckedThrowingContinuation() { continuation in
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if let error { continuation.resume(throwing: error) }
                if let authResult { continuation.resume(returning: authResult) }
            }
        }
    }
    
    public func signup(email: String, password: String) async throws -> AuthDataResult {
        return try await withCheckedThrowingContinuation() {
            continuation in
            Auth.auth().createUser(withEmail: email, password: password) { result, error in
                if let error { continuation.resume(throwing: error) }
                if let result { continuation.resume(returning: result) }
            }
        }
    }
    
    public func save(data: [String: String], into collection: String) async throws {
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
    
    public func fetchAgainstId(_ id: String, from collection: String) async throws -> QuerySnapshot {
        return try await db.collection(collection).whereField("id", isEqualTo: id).getDocuments()
    }
    
    public func parseLoginError(_ error: NSError) -> (message: String, code: Int)? {
        guard error.domain == AuthErrorDomain else {
            print("Error domain does not match.")
            return nil
        }
        
        guard let underlyingError = error.userInfo[NSUnderlyingErrorKey] as? NSError else { return nil }
        
        guard let underlyingError2 = underlyingError.userInfo[NSUnderlyingErrorKey] as? NSError,
              let data = underlyingError2.userInfo["data"] as? Data else { return nil }
        
        do {
            guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {return nil}
            guard let errorDetails = json["error"] as? [String: Any] else {return nil}
            
            guard let message = errorDetails["message"] as? String,
                  let code = errorDetails["code"] as? Int else {return nil}
            
            return (message, code)
            
        } catch {
            print("Failed to parse JSON data: \(error.localizedDescription)")
            return nil
        }
    }
    
    public func parseSignupError(_ error: NSError) -> (message: String, code: Int)? {
        guard error.domain == AuthErrorDomain else {
            print("Error domain is not AuthErrorDomain")
            return nil
        }
        
        if let errorCode = AuthErrorCode(rawValue: error.code) {
            switch errorCode {
            case .emailAlreadyInUse:
                return ("The email address is already in use by another account.", error.code)
            case .invalidEmail:
                return ("The email address is badly formatted.", error.code)
            case .wrongPassword:
                return ("The password is invalid or the user does not have a password.", error.code)
            case .userNotFound:
                return ("There is no user record corresponding to this identifier.", error.code)
            case .userDisabled:
                return ("The user account has been disabled by an administrator.", error.code)
            case .weakPassword:
                return ("The password must be 6 characters long or more.", error.code)
            default:
                return (error.localizedDescription, error.code)
            }
        }
        
        return nil
    }
}
