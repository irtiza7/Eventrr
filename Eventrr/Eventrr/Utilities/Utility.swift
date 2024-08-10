//
//  Utility.swift
//  Eventrr
//
//  Created by Dev on 8/19/24.
//

import Foundation

struct Utility {
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
    
    static func formatDateAndTime(
        dateString: String,
        fromTimeString: String,
        toTimeString: String) -> (dateFormatted: String, timeFormatted: String) {
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
            
            guard let date = dateFormatter.date(from: dateString),
                  let fromTime = dateFormatter.date(from: fromTimeString),
                  let toTime = dateFormatter.date(from: toTimeString) else {
                return ("Invalid Date", "Invalid Time")
            }
            
            dateFormatter.dateFormat = "E d MMM"
            let dateFormatted = dateFormatter.string(from: date)
            
            dateFormatter.dateFormat = "h:mm a"
            let fromTimeFormatted = dateFormatter.string(from: fromTime)
            let toTimeFormatted = dateFormatter.string(from: toTime)
            let timeFormatted = "\(fromTimeFormatted) - \(toTimeFormatted)"
            
            return (dateFormatted, timeFormatted)
        }
}
