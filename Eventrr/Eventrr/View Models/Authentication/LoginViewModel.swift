//
//  LoginViewModel.swift
//  Eventrr
//
//  Created by Dev on 8/5/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import RealmSwift

/// The `LoginViewModel` class handles the user login process, including fetching user information, checking if the user is already logged in,
/// and validating user credentials. It also manages the state of the login process using `@Published` properties to update the UI
/// in response to changes.
/// > Important: Requires Firebase SDK to be installed and GoogleService-Infor.plist file to be present in the project.
final class LoginViewModel {
    
    static let identifier = String(describing: LoginViewModel.self)
    
    // MARK: - Private Properties
    
    private var realmService: RealmService?
    
    // MARK: - Public Properties

    @Published public var loginStatus: LoginStatus?
    @Published public var userInformationStatus: UserInformationStatus?
    @Published public var isUserAlreadyLoggedIn: IsUserAlreadyLoggedIn?
    
    init(realmService: RealmService? = RealmService.shared) {
        guard let realmService else {
            RealmService.createInstance()
            if let service = RealmService.shared { self.realmService = service }
            return
        }
        self.realmService = realmService
    }
    
    // MARK: - Private Methods
    
    /// Initializes the `UserService` with the user's data retrieved from Firestore.
    /// - Parameters:
    ///   - document: The Firestore document snapshot containing the user's data.
    ///   - authId: The Firebase Auth ID of the user.
    ///   - email: The email address of the user.
    private func initializeUserService(document: QueryDocumentSnapshot, authId: String, email: String) {
        let data = document.data()
        
        guard let id = data[DatabaseTableColumns.Users.id.rawValue] as? String,
              let name = data[DatabaseTableColumns.Users.name.rawValue] as? String,
              let role = UserRole(rawValue: data[DatabaseTableColumns.Users.type.rawValue] as? String ?? "") 
        else {return}
        
        let userModel = UserModel(id: id, authId: authId, email: email, name: name, role: role)
        UserService.createInstance(userModel: userModel)
        
        Task { @MainActor in
            realmService?.saveUserDataToLocalStorage(user: userModel)
        }
    }
    
    
    
    /// Fetches the user's information from Firestore using their Firebase Auth ID.
    /// - Parameter authId: The Firebase Auth ID of the user.
    /// - Returns: A `QueryDocumentSnapshot` containing the user's information, if found.
    private func fetchUserInformation(authId: String) async throws -> QueryDocumentSnapshot? {
        let querySnapshot = try await FirebaseService.shared.fetchDataAgainst(
            value: authId,
            column: DatabaseTableColumns.Users.authId.rawValue,
            table: DatabaseTables.Users.rawValue
        )
        let document = querySnapshot.documents.first(where: {
            let data = $0.data()
            return (data[DatabaseTableColumns.Users.authId.rawValue] as? String) == authId
        })
        return document
    }
    
    
    // MARK: - Public Methods
    
    @MainActor
    public func initializeUserServiceFromLocalRecord() {
        guard let realmService else {
            userInformationStatus = .failure(errorMessage: K.StringMessages.somethingWentWrong)
            return
        }
        
        let results = realmService.fetchAllObjects(ofType: UserRealmModel.self)
        guard let user = results.first else {return}
        
        guard let id = user.id, let name = user.name,
              let role = UserRole(rawValue: user.role ?? "")
        else {
            userInformationStatus = .failure(errorMessage: K.StringMessages.somethingWentWrong)
            return
        }
        
        let userModel = UserModel(id: id, authId: user.authId, email: user.email, name: name, role: role)
        UserService.createInstance(userModel: userModel)
        userInformationStatus = .saved
    }
    
    /// Checks whether the user is already logged in and reloads the user object if necessary.
    ///
    ///This is important if the user's password has been updated while logged in.
    public func checkUserLoggedInStatus() {
        if NetworkConnectionStatusService.shared.isNetworkAvailable() {
            Auth.auth().currentUser?.reload { [weak self] error in
                if let error {
                    print("[\(LoginViewModel.identifier)] - Error: \n\(error)]")
                    
                    guard let error = FirebaseService.shared.parseCredentialsNoLongerValiedError(error as NSError) else {return}
                    self?.isUserAlreadyLoggedIn = .failure(errorMessage: error.message)
                    return
                }
                self?.isUserAlreadyLoggedIn = .loggedIn
            }
        } else {
            guard let _ = Auth.auth().currentUser else {return}
            isUserAlreadyLoggedIn = .loggedInButOffline
        }
    }
    
    /// Logs in the user with the provided email and password.
    /// Updates the `loginStatus` property based on the success or failure of the login attempt.
    /// - Parameters:
    ///   - email: The email address of the user.
    ///   - password: The password of the user.
    public func loginUser(email: String, password: String) {
        Task {
            do {
                let _ = try await FirebaseService.shared.login(email: email, password: password)
                loginStatus = .success
            } catch {
                print("[\(LoginViewModel.identifier)] - Error: \n\(error)]")
                
                guard let parsedError = FirebaseService.shared.parseLoginError(error as NSError) else {return}
                loginStatus = .failure(errorMessage: parsedError.message)
            }
        }
    }
    
    /// Validates whether the required user information exists in Firestore.
    /// If successful, initializes the `UserService` with the retrieved user data.
    public func validateUserRequiredInformation() {
        guard let user = Auth.auth().currentUser, let email = user.email else {
            userInformationStatus = .failure(errorMessage: K.StringMessages.somethingWentWrong)
            return
        }
        let authId = user.uid
        
        Task {
            do {
                guard let document = try await fetchUserInformation(authId: authId) else {
                    userInformationStatus = .notSaved
                    return
                }
                initializeUserService(document: document, authId: authId, email: email)
                userInformationStatus = .saved
            } catch {
                userInformationStatus = .failure(errorMessage: K.StringMessages.somethingWentWrong)
            }
        }
    }
    
    /// Validates the form by checking if the email and password error labels are hidden.
    /// - Parameters:
    ///   - emailErrorLabel: The label displaying the email error message.
    ///   - passwordLabel: The label displaying the password error message.
    /// - Returns: A boolean indicating whether the form is valid (both error labels are hidden).
    public func validateForm(_ emailErrorLabel: UILabel, _ passwordLabel: UILabel) -> Bool {
        emailErrorLabel.isHidden && passwordLabel.isHidden
    }
}

enum LoginStatus {
    case success, failure(errorMessage: String)
}

enum UserInformationStatus {
    case saved, notSaved, failure(errorMessage: String)
}

enum IsUserAlreadyLoggedIn {
    case loggedIn, loggedInButOffline, failure(errorMessage: String)
}
