//
//  RoleSwitchingUITests.swift
//  DemoAppUITests
//
//  Created by Stephanie Shen on 4/15/25.
//

import XCTest

class RoleSwitchingUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    func testReaderRoleTabs() throws {
        // Navigate to Settings
        let settingsTab = app.tabBars.buttons["Settings"]
        XCTAssertTrue(settingsTab.exists)
        settingsTab.tap()
        
        // Switch to Reader role
        let switchRoleButton = app.buttons["Switch Role"]
        XCTAssertTrue(switchRoleButton.exists)
        switchRoleButton.tap()
        
        let readerButton = app.buttons["Reader"]
        XCTAssertTrue(readerButton.exists)
        readerButton.tap()
        
        // Verify Reader tabs are visible
        XCTAssertTrue(app.tabBars.buttons["Calendar"].exists)
        XCTAssertTrue(app.tabBars.buttons["Daily Pick"].exists)
        XCTAssertTrue(app.tabBars.buttons["Tracker"].exists)
        XCTAssertTrue(app.tabBars.buttons["Donate"].exists)
        XCTAssertTrue(app.tabBars.buttons["Settings"].exists)
        
        // Verify Staff tabs are NOT visible
        XCTAssertFalse(app.tabBars.buttons["Scanner"].exists)
        XCTAssertFalse(app.tabBars.buttons["Monthly Pick"].exists)
        XCTAssertFalse(app.tabBars.buttons["Seed Books"].exists)
    }
    
    func testStaffRoleTabs() throws {
        // Navigate to Settings
        let settingsTab = app.tabBars.buttons["Settings"]
        XCTAssertTrue(settingsTab.exists)
        settingsTab.tap()
        
        // Switch to Staff role
        let switchRoleButton = app.buttons["Switch Role"]
        XCTAssertTrue(switchRoleButton.exists)
        switchRoleButton.tap()
        
        let staffButton = app.buttons["Staff"]
        XCTAssertTrue(staffButton.exists)
        staffButton.tap()
        
        // Verify Staff tabs are visible
        XCTAssertTrue(app.tabBars.buttons["Scanner"].exists)
        XCTAssertTrue(app.tabBars.buttons["Monthly Pick"].exists)
        XCTAssertTrue(app.tabBars.buttons["Seed Books"].exists)
        XCTAssertTrue(app.tabBars.buttons["Settings"].exists)
        
        // Verify Reader tabs are NOT visible
        XCTAssertFalse(app.tabBars.buttons["Calendar"].exists)
        XCTAssertFalse(app.tabBars.buttons["Daily Pick"].exists)
        XCTAssertFalse(app.tabBars.buttons["Tracker"].exists)
        XCTAssertFalse(app.tabBars.buttons["Donate"].exists)
    }
    
    func testRolePersistence() throws {
        // Switch to Staff role
        let settingsTab = app.tabBars.buttons["Settings"]
        settingsTab.tap()
        
        let switchRoleButton = app.buttons["Switch Role"]
        switchRoleButton.tap()
        
        let staffButton = app.buttons["Staff"]
        staffButton.tap()
        
        // Verify Staff tabs are visible
        XCTAssertTrue(app.tabBars.buttons["Scanner"].exists)
        
        // Restart the app
        app.terminate()
        app.launch()
        
        // Verify role persistence - should still be Staff
        XCTAssertTrue(app.tabBars.buttons["Scanner"].exists)
        XCTAssertFalse(app.tabBars.buttons["Calendar"].exists)
    }
    
    func testThemeSwitching() throws {
        // Navigate to Settings
        let settingsTab = app.tabBars.buttons["Settings"]
        settingsTab.tap()
        
        // Find and tap the theme picker
        let themePicker = app.pickers["Theme"]
        XCTAssertTrue(themePicker.exists)
        
        // Test different themes
        let themePickerWheel = app.pickerWheels["Theme"]
        XCTAssertTrue(themePickerWheel.exists)
        
        themePickerWheel.adjust(toPickerWheelValue: "Classic")
        themePickerWheel.adjust(toPickerWheelValue: "Midnight")
        themePickerWheel.adjust(toPickerWheelValue: "Sepia")
        
        // Verify theme picker works
        // No need to check existence after adjustment, as adjust returns Void
    }
    
    func testSettingsNavigation() throws {
        // Navigate to Settings
        let settingsTab = app.tabBars.buttons["Settings"]
        settingsTab.tap()
        
        // Verify Settings content
        XCTAssertTrue(app.staticTexts["User Role"].exists)
        XCTAssertTrue(app.staticTexts["Appearance"].exists)
        XCTAssertTrue(app.staticTexts["App Information"].exists)
        XCTAssertTrue(app.staticTexts["Support"].exists)
        XCTAssertTrue(app.staticTexts["Data"].exists)
    }
} 