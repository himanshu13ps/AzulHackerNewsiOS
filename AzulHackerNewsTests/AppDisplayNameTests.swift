import XCTest
@testable import AzulHackerNews

final class AppDisplayNameTests: XCTestCase {
    
    func testBundleDisplayName() {
        // Test that the app's display name is correctly set to "Azul HN"
        let displayName = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
        XCTAssertEqual(displayName, "Azul HN", "App display name should be 'Azul HN'")
    }
    
    func testBundleDisplayNameIsNotEmpty() {
        // Ensure the display name is not nil or empty
        let displayName = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
        XCTAssertNotNil(displayName, "Display name should not be nil")
        XCTAssertFalse(displayName?.isEmpty ?? true, "Display name should not be empty")
    }
    
    func testProjectStructureRemainsSame() {
        // Verify that internal project structure remains unchanged
        let bundleIdentifier = Bundle.main.bundleIdentifier
        XCTAssertEqual(bundleIdentifier, "himanshu13ps.AzulHackerNews", "Bundle identifier should remain unchanged")
        
        let productName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String
        // The product name might be different from display name, which is expected
        XCTAssertNotNil(productName, "Product name should exist")
    }
}