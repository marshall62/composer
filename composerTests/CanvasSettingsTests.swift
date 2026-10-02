//
//  CanvasSettingsTests.swift
//  composer
//
//  Created by David Marshall on 9/15/26.
//

import Testing
@testable import composer

struct CanvasSettingsTests {
    @Test func zeroWidthIsBlocked() {
        let settings = CanvasSettings(width: 0, height: 10, gridType: .fourByFour)
        let errors = blockingErrors(for: settings)
        #expect(!errors.isEmpty)
    }
    
    @Test func validWidthsSucceed() {
        let settings = CanvasSettings(width: 10, height: 16, gridType: .fourByFour)
        let errors = blockingErrors(for: settings)
        #expect(errors.isEmpty)
    }
    
    @Test func invalidCustomSquareIsBlocked() {
        let settings = CanvasSettings(width: 10, height: 16, gridType: .customSquare(size: -4))
        let errors = blockingErrors(for: settings)
        #expect(!errors.isEmpty)
    }
    
    @Test func canvasSizeNonDivisibleBySquareSize () {
        let settings = CanvasSettings(width: 10, height: 16, gridType: .customSquare(size: 4))
        let warnings = warnings(for: settings)
        #expect(!warnings.isEmpty)
    }
    
    @Test func canvasSizeDivisibleBySquareSize () {
        let settings = CanvasSettings(width: 12, height: 16, gridType: .customSquare(size: 4))
        let warnings = warnings(for: settings)
        #expect(warnings.isEmpty)
    }
    
    @Test func itEvenlyDivides() {
        let res = evenlyDivides(4, into:16);
        #expect(res)
    }
    
    @Test func itDoesntEvenlyDivides() {
        let res = evenlyDivides(3, into:16);
        #expect(!res)
    }

}
