//
//  UserService.swift
//  Eventrr
//
//  Created by Dev on 8/12/24.
//

/// A singleton service class that manages the current user's data throughout the application.
/// Conforms to `UserServiceProtocol` to expose the current user.
final class UserService: UserServiceProtocol {
    
    static var shared: UserService?
    
    /// Creates a singleton instance of `UserService` if one does not already exist.
    /// - Parameter userModel: The user data to initialize the service with.
    static func createInstance(userModel: UserModel) {
        if UserService.shared == nil {
            UserService.shared = UserService(userModel)
        }
    }
    
    public private(set) var user: UserModel
    
    private init(_ user: UserModel) {
        self.user = user
    }
}

/// A protocol defining the necessary properties for a user service.
/// Conforming types must provide access to a user data model.
protocol UserServiceProtocol {
    var user: UserModel {get}
}
