//
//  ErrorTypes.swift
//  Eventrr
//
//  Created by Dev on 8/3/24.
//

import Foundation

enum LoginError: Int, Error {
    case INVALID_LOGIN_CREDENTIALS = 400
    
    var message: String {
        switch self {
        case .INVALID_LOGIN_CREDENTIALS:
            return "Invalid email or password."
        }
    }
}

enum SignupError: Int, Error {
    case ERROR_EMAIL_ALREADY_IN_USE = 17007
    
    var message: String {
        switch self {
        case .ERROR_EMAIL_ALREADY_IN_USE:
            return "Email already in use."
        }
    }
}
