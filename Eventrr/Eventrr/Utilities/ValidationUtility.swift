//
//  Utility.swift
//  Eventrr
//
//  Created by Dev on 8/19/24.
//

import Foundation

struct ValidationUtility {
    static func validateEmail(_ value: String) -> String? {
        if value.count == 0 { return K.StringMessages.requiredFieldString }
        
        let predicate = NSPredicate(format:"SELF MATCHES %@", K.StringMessages.emailRegex)
        if !(predicate.evaluate(with: value)) {
            return K.StringMessages.enterValidEmailErrorString
        }
        return nil
    }
    
    static func validatePassword(_ value: String) -> String? {
        if value.count == 0 { return K.StringMessages.requiredFieldString }
        if value.count < 8 { return K.StringMessages.passwordLengthErrorString }
        return nil
    }
    
    static func validatePasswordAndConfirmPassword(_ password: String, _ confirmPassword: String) -> String? {
        if confirmPassword.count == 0 { return K.StringMessages.requiredFieldString }
        else if password != confirmPassword { return K.StringMessages.passwordsMismatchErrorString }
        return nil
    }
    
    static func validateTexualFieldContainsText(_ text: String?) -> String? {
        guard let text else {
            return K.StringMessages.requiredFieldString
        }
        
        if text.trimmingCharacters(in: .whitespaces) == "" {
            return K.StringMessages.fieldMustContainSomeText
        }
        return nil
    }
}
