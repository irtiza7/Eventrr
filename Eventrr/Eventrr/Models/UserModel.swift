//
//  UserModel.swift
//  Eventrr
//
//  Created by Dev on 8/5/24.
//

import Foundation

struct UserModel: Decodable {
    let id: String
    let email: String
    let name: String?
    let type: String?
}
