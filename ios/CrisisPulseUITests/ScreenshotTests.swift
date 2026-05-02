//
//  ScreenshotTests.swift
//  CrisisPulseUITests
//
//  Drives the app through 5 representative states and saves App Store
//  screenshots as XCTest attachments. Run with:
//      xcodebuild test -scheme CrisisPulse -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max'
//  The screenshots end up in DerivedData test results bundle and can be
//  extracted with `xcparse`.
//

import XCTest

final class ScreenshotTests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false

        // Auto-dismiss any system permission dialogs (location, notifications)
        // that pop over the app.
        addUIInterruptionMonitor(withDescription: "System Permission Dialog") { alert in
            // Try common allow buttons in EN + ZH
            let candidates = [
                "Allow While Using App",
                "Allow",
                "OK",
                "使用 App 时允许",
                "允许",
                "好"
            ]
            for label in candidates {
                let btn = alert.buttons[label]
                if btn.exists {
                    btn.tap()
                    return true
                }
            }
            return false
        }
    }

    func testCaptureAppStoreScreenshots() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
        app.launch()

        // Nudge a tap so the interruption monitor fires for any loc dialog
        sleep(2)
        app.tap()
        sleep(8)  // Wait for /api/conflicts to return + map render

        // ---------- 1. Map view collapsed (hero card visible) ----------
        snapshot(app, name: "01-map")

        // ---------- 2. Expand news card by tapping the header ----------
        // The card header is a button containing "Today's Key Developments"
        let newsHeader = app.buttons.matching(
            NSPredicate(format: "label CONTAINS[c] 'developments'")
        ).firstMatch
        if newsHeader.waitForExistence(timeout: 3) {
            newsHeader.tap()
            sleep(2)
        }
        snapshot(app, name: "02-news-expanded")

        // Collapse it back so we don't carry it over to other tabs visually
        if newsHeader.exists { newsHeader.tap(); sleep(1) }

        // ---------- 3. Calculator tab ----------
        let calcTab = app.tabBars.buttons.element(boundBy: 1)
        XCTAssertTrue(calcTab.waitForExistence(timeout: 3), "Calculator tab not found")
        calcTab.tap()
        sleep(2)
        snapshot(app, name: "03-calculator")

        // Scroll down a bit to reveal the household/months sliders
        app.swipeUp()
        sleep(1)
        snapshot(app, name: "03b-calculator-household")

        // Generate the supply list
        let generateBtn = app.buttons.matching(
            NSPredicate(format: "label CONTAINS[c] 'Generate' OR label CONTAINS[c] 'My Supply'")
        ).firstMatch
        if generateBtn.waitForExistence(timeout: 3) {
            generateBtn.tap()
            sleep(2)
        }
        snapshot(app, name: "04-calculator-result")

        // ---------- 5. Settings tab ----------
        let settingsTab = app.tabBars.buttons.element(boundBy: 2)
        XCTAssertTrue(settingsTab.waitForExistence(timeout: 3), "Settings tab not found")
        settingsTab.tap()
        sleep(2)
        snapshot(app, name: "05-settings")
    }

    private func snapshot(_ app: XCUIApplication, name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
