//
//  ValidationUtilityTests.swift
//  EventrrTests
//
//  Created by Irtiza on 9/2/24.
//

import XCTest
@testable import Eventrr

final class ValidationUtilityTests: XCTestCase {

    func testValidateEmail_EmptyEmail() {
        let result = ValidationUtility.validateEmail("")
        XCTAssertEqual(result, K.StringMessages.requiredFieldString)
    }

    func testValidateEmail_InvalidFormatEmail() {
        let result = ValidationUtility.validateEmail("invalidEmail")
        XCTAssertEqual(result, K.StringMessages.enterValidEmailErrorString)
    }

    func testValidateEmail_ValidFormat() {
        let result = ValidationUtility.validateEmail("test@example.com")
        XCTAssertNil(result)
    }

    func testValidatePassword_EmaptyPassword() {
        let result = ValidationUtility.validatePassword("")
        XCTAssertEqual(result, K.StringMessages.requiredFieldString)
    }

    func testValidatePassword_ShortPassword() {
        let result = ValidationUtility.validatePassword("short")
        XCTAssertEqual(result, K.StringMessages.passwordLengthErrorString)
    }

    func testValidatePassword_ValidPassword() {
        let result = ValidationUtility.validatePassword("validPassword")
        XCTAssertNil(result)
    }

    func testValidatePasswordAndConfirmPassword_ConfirmPasswordEmpty() {
        let result = ValidationUtility.validatePasswordAndConfirmPassword("validPassword", "")
        XCTAssertEqual(result, K.StringMessages.requiredFieldString)
    }

    func testValidatePasswordAndConfirmPassword_PasswordsDoNotMatch() {
        let result = ValidationUtility.validatePasswordAndConfirmPassword("password123", "password456")
        XCTAssertEqual(result, K.StringMessages.passwordsMismatchErrorString)
    }

    func testValidatePasswordAndConfirmPassword_PasswordsMatch() {
        let result = ValidationUtility.validatePasswordAndConfirmPassword("password123", "password123")
        XCTAssertNil(result)
    }

    func testValidateTexualFieldContainsText_EmptyField() {
        let result = ValidationUtility.validateTexualFieldContainsText(nil)
        XCTAssertEqual(result, K.StringMessages.requiredFieldString)
    }

    func testValidateTexualFieldContainsText_TextContainingOnlyWhiteSpaces() {
        let result = ValidationUtility.validateTexualFieldContainsText(" ")
        XCTAssertEqual(result, K.StringMessages.fieldMustContainSomeText)
    }

    func testValidateTexualFieldContainsText_ValidText() {
        let result = ValidationUtility.validateTexualFieldContainsText("Valid text")
        XCTAssertNil(result)
    }
}

