//
//  UserService.swift
//  Eventrr
//
//  Created by Dev on 8/12/24.
//

final class UserService: UserServiceProtocol {
    
    static var shared: UserService?
    
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

protocol UserServiceProtocol {
    var user: UserModel {get}
}
