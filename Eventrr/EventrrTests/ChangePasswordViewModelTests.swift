//
//  ChangePasswordViewModelTests.swift
//  EventrrTests
//
//  Created by Irtiza on 9/2/24.
//

import XCTest
@testable import Eventrr

final class ChangePasswordViewModelTests: XCTestCase {
    
    private var viewModel: ChangePasswordViewModel!
    private var mockUser: UserModel!

    override func setUpWithError() throws {
        let mockUser = UserModel(id: "1", authId: "abc", email: "test@example.com", name: "Test User", role: .Admin)
        
        self.mockUser = mockUser
        viewModel = ChangePasswordViewModel(userService: MockUserService(user: mockUser))
    }

    override func tearDownWithError() throws {
        viewModel = nil
    }

    func testValidateFields_AllFieldsEmpty_ReturnsRequiredFieldString() throws {
        viewModel.userEmail = ""
        viewModel.currentPassword = ""
        viewModel.newPassword = ""
        viewModel.confirmPassword = ""
        
        let result = try viewModel.validateFields()
        XCTAssertEqual(result, K.StringMessages.requiredFieldString)
    }
    
    func testValidateFields_EmailInvalid_ReturnsErrorMessage() throws {
        viewModel.userEmail = "invalidEmail"
        viewModel.currentPassword = "validPassword123"
        viewModel.newPassword = "newValidPassword123"
        viewModel.confirmPassword = "newValidPassword123"
        
        let result = try viewModel.validateFields()
        XCTAssertEqual(result, K.StringMessages.enterValidEmailErrorString)
    }

    func testValidateFields_EmailDoesNotMatch_ReturnsErrorMessage() throws {
        viewModel.userEmail = "notmatching@example.com"
        viewModel.currentPassword = "validPassword123"
        viewModel.newPassword = "newValidPassword123"
        viewModel.confirmPassword = "newValidPassword123"
        
        let result = try viewModel.validateFields()
        XCTAssertEqual(result, "Entered email doesn't match with account email.")
    }

    func testValidateFields_CurrentPasswordInvalid_ReturnsErrorMessage() throws {
        viewModel.userEmail = "test@example.com"
        viewModel.currentPassword = "short"
        viewModel.newPassword = "newValidPassword123"
        viewModel.confirmPassword = "newValidPassword123"
        
        let result = try viewModel.validateFields()
        XCTAssertEqual(result, "Enter a valid current password.")
    }

    func testValidateFields_NewPasswordInvalid_ReturnsErrorMessage() throws {
        viewModel.userEmail = "test@example.com"
        viewModel.currentPassword = "validPassword123"
        viewModel.newPassword = "short"
        viewModel.confirmPassword = "short"
        
        let result = try viewModel.validateFields()
        XCTAssertEqual(result, "Enter a valid new password.")
    }

    func testValidateFields_NewPasswordSameAsCurrent_ReturnsErrorMessage() throws {
        viewModel.userEmail = "test@example.com"
        viewModel.currentPassword = "validPassword123"
        viewModel.newPassword = "validPassword123"
        viewModel.confirmPassword = "validPassword123"
        
        let result = try viewModel.validateFields()
        XCTAssertEqual(result, "New password is same as old password.")
    }
    
    func testValidateFields_NewPasswordAndConfirmPasswordDoNotMatch_ReturnsErrorMessage() throws {
        viewModel.userEmail = "test@example.com"
        viewModel.currentPassword = "validPassword123"
        viewModel.newPassword = "newValidPassword123"
        viewModel.confirmPassword = "differentPassword123"
        
        let result = try viewModel.validateFields()
        XCTAssertEqual(result, K.StringMessages.passwordsMismatchErrorString)
    }

    func testValidateFields_AllValid_ReturnsNil() throws {
        viewModel.userEmail = "test@example.com"
        viewModel.currentPassword = "validPassword123"
        viewModel.newPassword = "newValidPassword123"
        viewModel.confirmPassword = "newValidPassword123"
        
        let result = try viewModel.validateFields()
        XCTAssertNil(result)
    }
}

final class MockUserService: UserServiceProtocol {
    var user: UserModel
    
    init(user: UserModel) {
        self.user = user
    }
}
