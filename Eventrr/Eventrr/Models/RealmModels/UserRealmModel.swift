//
//  UserRealmModel.swift
//  Eventrr
//
//  Created by Irtiza on 8/31/24.
//

import Foundation
import RealmSwift

class UserRealmModel: Object {
    @Persisted(primaryKey: true) var id: String? = ""
    @Persisted var authId: String = ""
    @Persisted var email: String = ""
    @Persisted var name: String? = ""
    @Persisted var role: String? = ""
}
