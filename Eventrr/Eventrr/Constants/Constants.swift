//
//  Constants.swift
//  Eventrr
//
//  Created by Dev on 8/6/24.
//

import Foundation

struct K {
    enum ColorConstants: String {
        case WhitePrimary, BlackPrimary, AccentPrimary, AccentSecondary, AccentRed
    }
    
    struct AuthConstants {
        static let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        static let errorTitle = "Error"
        static let loginFailurePopupTitle = "Login Failed"
        static let signupFailurePopupTitle = "Signup Failed"
        
        static let requiredFieldString = "Required"
        static let emailSentSuccessString = "Email send successfully."
        static let enterValidEmailErrorString = "Please enter a valid email"
        static let passwordLengthErrorString = "Password should be of length 8"
        static let passwordsMismatchErrorString = "Passwords do not match"
        
        static let errorPopupActionButtonTitle = "Retry"
        static let successPopActionButtonTitle = "Okay"
    }
    
    struct StoryboardIdentifiers {
        static let mainBundleStoryboard = "Main"
        
        static let authNavigationController = "AuthNavigationController"
        static let loginViewController = "LoginViewController"
        static let signupViewController = "SIgnupViewController"
        static let forgotPasswordViewController = "ForgotPasswordViewController"
        static let nameAndRoleViewController = "NameAndRoleViewController"
    }
    
    struct ErrorMessages {
        static let somethingWentWrong = "Something went wrong. Please try again later."
    }
}
