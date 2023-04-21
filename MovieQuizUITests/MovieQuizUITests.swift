//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//  Created by Артём Костянко on 9.04.23.
//

import XCTest

final class MovieQuizUITests: XCTestCase {
    
    var app: XCUIApplication!

    override func setUpWithError() throws {
        app = XCUIApplication()
        app.launch()
        
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        app.terminate()
        app = nil
    }

    func testExample() throws {
        let app = XCUIApplication()
        app.launch()
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
    
    func testYesButton() {
        sleep(3)
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        app.buttons["Yes"].tap()
        sleep(3)
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        let indexLabel = app.staticTexts["Index"]
        XCTAssertNotEqual(firstPosterData, secondPosterData)
        XCTAssertEqual(indexLabel.label, "2/10")
    }
    
    func testNoButton() {
        sleep(3)
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        app.buttons["No"].tap()
        sleep(3)
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        let indexLabel = app.staticTexts["Index"]
        XCTAssertNotEqual(firstPosterData, secondPosterData)
        XCTAssertEqual(indexLabel.label, "2/10")
    }
    
    func testGameResultsAlert() {
        sleep(3)
        for _ in 1...10 {
            app.buttons["Yes"].tap()
            sleep(3)
        }
        let alert = app.alerts["Game results"]
        XCTAssertTrue(alert.exists)
        XCTAssertTrue(alert.buttons.firstMatch.label == "Сыграть ещё раз!")
        XCTAssertTrue(alert.label == "Этот раунд окончен!")
    }
    
    func testAlertTapButton() {
        sleep(3)
        for _ in 1...10 {
            app.buttons["Yes"].tap()
            sleep(3)
        }
        let alert = app.alerts["Game results"]
        alert.buttons.firstMatch.tap()
        sleep(3)
        let indexLabel = app.staticTexts["Index"]
        XCTAssertFalse(alert.exists)
        XCTAssertTrue(indexLabel.label == "1/10")
    }
    
    
}
