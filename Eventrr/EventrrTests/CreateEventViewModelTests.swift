//
//  CreateEventViewModelTests.swift
//  EventrrTests
//
//  Created by Irtiza on 9/2/24.
//

import XCTest
@testable import Eventrr

final class CreateEventViewModelTests: XCTestCase {
    
    private var viewModel: CreateEventViewModel!
    
    override func setUpWithError() throws {
        viewModel = CreateEventViewModel()
    }
    
    override func tearDownWithError() throws {
        viewModel = nil
    }
    
    func testValidateDateAndTime_StartTimeOneHourAfterCurrentTime() {
        let calendar = Calendar.current
        let todayAt9AM = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: Date())!
        let oneMinuteFromNow = calendar.date(byAdding: .minute, value: 1, to: todayAt9AM)!
        let toTime = calendar.date(byAdding: .hour, value: 2, to: todayAt9AM)!
        
        let validationResult = viewModel.validateDateAndTime(
            selectedDate: todayAt9AM,
            fromTime: oneMinuteFromNow,
            toTime: toTime
        )
        
        XCTAssertEqual(validationResult, K.StringMessages.startTimeOneHourAfterCurrentTime)
    }
    
    func testValidateDateAndTime_StartTimeMustPrecedeEndTime() {
        let calendar = Calendar.current
        let today = Date()
        let startTime = calendar.date(byAdding: .hour, value: 2, to: today)!
        let endTime = calendar.date(byAdding: .hour, value: 0, to: today)!
        
        let validationResult = viewModel.validateDateAndTime(
            selectedDate: today,
            fromTime: startTime,
            toTime: endTime
        )
        
        XCTAssertEqual(validationResult, K.StringMessages.startTimeMustPrecedeEndTime)
    }
    
    func testValidateDateAndTime_DateNotToday() {
        let calendar = Calendar.current
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date())!
        let startTime = calendar.date(bySettingHour: 10, minute: 0, second: 0, of: tomorrow)!
        let endTime = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: tomorrow)!
        
        let validationResult = viewModel.validateDateAndTime(
            selectedDate: tomorrow,
            fromTime: startTime,
            toTime: endTime
        )
        
        XCTAssertNil(validationResult)
    }
}
