//
//  UserModel.swift
//  Eventrr
//
//  Created by Dev on 8/5/24.
//

import Foundation

struct UserModel: Codable {
    let id: String?
    let authId: String
    let email: String
    let name: String?
    let role: UserRole?
}
