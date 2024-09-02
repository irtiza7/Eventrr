//
//  ProfileViewModel.swift
//  Eventrr
//
//  Created by Dev on 8/21/24.
//

import Foundation
import FirebaseAuth

class UserProfileViewModel: ObservableObject {
    
    public var userModel: UserModel?
    
    init() {
        initUserModel()
    }
    
    public func initUserModel() {
        guard let user =  UserService.shared?.user else {return}
        userModel = user
    }
    
    public func logout() -> String? {
        do {
            try Auth.auth().signOut()
            UserService.shared = nil
            
            Task { @MainActor  in
                RealmService.shared?.deleteAllObjects(ofType: UserRealmModel.self)
            }
        } catch {
            print("[\(String(describing: UserProfileView.self))] - Error: \n\(error)")
            return K.StringMessages.somethingWentWrong
        }
        return nil
    }
}
