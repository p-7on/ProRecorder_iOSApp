//
//  ProRecorderTests.swift
//  ProRecorderTests
//
//  Created by Simon Puchner on 30.06.22.
//

import XCTest
@testable import ProRecorder

class ProRecorderTests: XCTestCase {
    
    var projectViewModel: ProjectViewModel!

    override func setUpWithError() throws {
        projectViewModel = ProjectViewModel()
    }

    override func tearDownWithError() throws {
        projectViewModel = nil
    }
    
    // ----------------------------------------------------------------------- //
    
    // TESTS
    func testConvertDateToStringTrue() {
        let date1 = projectViewModel.convertDateToString(date: Date())
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        let date2 = formatter.string(for: Date())
        
        XCTAssertTrue(date1 == date2)
    }
    
    func testConvertDateToStringFalse() {
        let date1 = projectViewModel.convertDateToString(date: Date())
        let date2 = "16.07.2022"
        
        XCTAssertFalse(date1 == date2)
        
        let date3 = "0.0.0000"
        XCTAssertFalse(date1 == date3)
        
        let date4 = "16-07-2022"
        XCTAssertFalse(date1 == date4)
    }
    
    func testConvertDateTimeToStringTrue() {
        let time1 = projectViewModel.convertDateTimeToString(date: Date())
        
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        let time2 = formatter.string(for: Date())
        
        XCTAssertTrue(time1 == time2)
    }
    
    func testConvertDateTimeToStringFalse() {
        let time1 = projectViewModel.convertDateTimeToString(date: Date())
        let time2 = "23:59:59"
        
        XCTAssertFalse(time1 == time2)
        
        let time3 = "00:00:00"
        XCTAssertFalse(time1 == time3)
        
        let time4 = "23.59.59"
        XCTAssertFalse(time1 == time4)
    }
    
    func testConvertSecToHMSTrue() {
        let HHMMSS1 = projectViewModel.convertSecToHMS(seconds: 180)
        let HHMMSS2 = "00:03:00"
        
        XCTAssertTrue(HHMMSS1 == HHMMSS2)
        
        let HHMMSS3 = projectViewModel.convertSecToHMS(seconds: 3601)
        let HHMMSS4 = "01:00:01"
        
        XCTAssertTrue(HHMMSS3 == HHMMSS4)
       
        
        let HHMMSS5 = projectViewModel.convertSecToHMS(seconds: 12408)
        let HHMMSS6 = "03:26:48"
        
        XCTAssertTrue(HHMMSS5 == HHMMSS6)
    }
    
    func testConvertSecToHMSFalse() {
        let HHMMSS1 = projectViewModel.convertSecToHMS(seconds: 180)
        let HHMMSS2 = "00:05:12"
        
        XCTAssertFalse(HHMMSS1 == HHMMSS2)
        
        let HHMMSS3 = projectViewModel.convertSecToHMS(seconds: 3601)
        let HHMMSS4 = "02:34:45"
        
        XCTAssertFalse(HHMMSS3 == HHMMSS4)
       
        
        let HHMMSS5 = projectViewModel.convertSecToHMS(seconds: 12408)
        let HHMMSS6 = "1:36:89"
        
        XCTAssertFalse(HHMMSS5 == HHMMSS6)
    }
}
