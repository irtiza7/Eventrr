//
//  LoginViewModel.swift
//  Eventrr
//
//  Created by Dev on 8/5/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class LoginViewModel {
    
    static let identifier = String(describing: LoginViewModel.self)
    
    // MARK: - Public Properties
    
    @Published public var loginStatus: LoginStatus?
    @Published public var userInformationStatus: UserInformationStatus?
    @Published public var isUserAlreadyLoggedIn: IsUserAlreadyLoggedIn?
    
    init() {}
    
    // MARK: - Private Methods
    
    private func initializeUserService(document: QueryDocumentSnapshot, authId: String, email: String) {
        let data = document.data()
        
        guard let id = data[DatabaseTableColumns.Users.id.rawValue] as? String,
              let name = data[DatabaseTableColumns.Users.name.rawValue] as? String,
              let role = UserRole(rawValue: data[DatabaseTableColumns.Users.type.rawValue] as? String ?? "") else {return}
        
        let userModel = UserModel(id: id, authId: authId, email: email, name: name, role: role)
        UserService.createInstance(userModel: userModel)
    }
    
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
    
    public func checkUserLoggedInStatus() {
        /*
         Have to reload current user object in case the user was logged in already
         but the password was updated
         */
        Auth.auth().currentUser?.reload { error in
            if let error {
                print("[\(LoginViewModel.identifier)] - Error: \n\(error)]")
                
                guard let error = FirebaseService.shared.parseCredentialsNoLongerValiedError(error as NSError) else {return}
                self.isUserAlreadyLoggedIn = .failure(errorMessage: error.message)
                
                return
            }
            self.isUserAlreadyLoggedIn = .loggedIn
        }
    }
    
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
                userInformationStatus = .saved
                initializeUserService(document: document, authId: authId, email: email)
            } catch {
                userInformationStatus = .failure(errorMessage: K.StringMessages.somethingWentWrong)
            }
        }
    }
    
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
    case loggedIn, failure(errorMessage: String)
}
