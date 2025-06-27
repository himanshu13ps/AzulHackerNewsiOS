import XCTest
@testable import AzulHackerNews

final class NetworkManagerTests: XCTestCase {
    var networkManager: NetworkManager!
    
    override func setUpWithError() throws {
        networkManager = NetworkManager()
    }
    
    override func tearDownWithError() throws {
        networkManager = nil
    }
    
    func testFetchTopStoryIds() async throws {
        // Test fetching story IDs from the API
        let storyIds = try await networkManager.fetchTopStoryIds()
        
        XCTAssertFalse(storyIds.isEmpty, "Story IDs should not be empty")
        XCTAssertTrue(storyIds.count > 0, "Should fetch multiple story IDs")
        
        // Verify all IDs are positive integers
        for id in storyIds {
            XCTAssertGreaterThan(id, 0, "Story ID should be positive")
        }
    }
    
    func testFetchNewStoryIds() async throws {
        // Test fetching new story IDs from the API
        let storyIds = try await networkManager.fetchNewStoryIds()
        
        XCTAssertFalse(storyIds.isEmpty, "New story IDs should not be empty")
        XCTAssertTrue(storyIds.count > 0, "Should fetch multiple new story IDs")
        
        // Verify all IDs are positive integers
        for id in storyIds {
            XCTAssertGreaterThan(id, 0, "Story ID should be positive")
        }
    }
    
    func testFetchStoryIdsByType() async throws {
        // Test fetching top stories by type
        let topStoryIds = try await networkManager.fetchStoryIds(for: .top)
        XCTAssertFalse(topStoryIds.isEmpty, "Top story IDs should not be empty")
        
        // Test fetching new stories by type
        let newStoryIds = try await networkManager.fetchStoryIds(for: .new)
        XCTAssertFalse(newStoryIds.isEmpty, "New story IDs should not be empty")
        
        // Verify all IDs are positive integers
        for id in topStoryIds + newStoryIds {
            XCTAssertGreaterThan(id, 0, "Story ID should be positive")
        }
    }
    
    func testFetchSingleStory() async throws {
        // First get some story IDs
        let storyIds = try await networkManager.fetchTopStoryIds()
        guard let firstId = storyIds.first else {
            XCTFail("No story IDs available for testing")
            return
        }
        
        // Test fetching a single story
        let story = try await networkManager.fetchStory(id: firstId)
        
        XCTAssertEqual(story.id, firstId, "Story ID should match requested ID")
        XCTAssertFalse(story.title.isEmpty, "Story should have a title")
        XCTAssertFalse(story.by.isEmpty, "Story should have an author")
        XCTAssertGreaterThan(story.time, 0, "Story should have a valid timestamp")
    }
    
    func testFetchMultipleStories() async throws {
        // Get some story IDs for testing
        let allStoryIds = try await networkManager.fetchTopStoryIds()
        let testIds = Array(allStoryIds.prefix(5)) // Test with first 5 IDs
        
        // Test fetching multiple stories
        let stories = try await networkManager.fetchStories(ids: testIds)
        
        XCTAssertFalse(stories.isEmpty, "Should fetch at least some stories")
        XCTAssertLessThanOrEqual(stories.count, testIds.count, "Should not fetch more stories than requested")
        
        // Verify story properties
        for story in stories {
            XCTAssertTrue(testIds.contains(story.id), "Fetched story ID should be in requested IDs")
            XCTAssertFalse(story.title.isEmpty, "Story should have a title")
            XCTAssertFalse(story.by.isEmpty, "Story should have an author")
        }
    }
    
    func testStoryTypesReturnDifferentResults() async throws {
        // Fetch both top and new story IDs
        let topStoryIds = try await networkManager.fetchTopStoryIds()
        let newStoryIds = try await networkManager.fetchNewStoryIds()
        
        // Both should have content
        XCTAssertFalse(topStoryIds.isEmpty, "Top stories should not be empty")
        XCTAssertFalse(newStoryIds.isEmpty, "New stories should not be empty")
        
        // Take first few IDs from each to compare
        let topSample = Array(topStoryIds.prefix(10))
        let newSample = Array(newStoryIds.prefix(10))
        
        // They should generally be different (though there might be some overlap)
        // We'll check that they're not identical arrays
        XCTAssertNotEqual(topSample, newSample, "Top and new story lists should generally be different")
    }
    
    func testInvalidStoryId() async {
        // Test fetching with an invalid ID
        do {
            _ = try await networkManager.fetchStory(id: -1)
            XCTFail("Should throw error for invalid story ID")
        } catch {
            // Expected to throw an error
            XCTAssertTrue(error is NetworkError || error is DecodingError)
        }
    }
    
    func testNetworkErrorHandling() async {
        // Test with invalid URL (this will test error handling)
        let invalidNetworkManager = NetworkManager()
        
        do {
            _ = try await invalidNetworkManager.fetchStories(ids: [999999999]) // Very high ID unlikely to exist
        } catch {
            // Should handle the error gracefully
            XCTAssertTrue(error is NetworkError)
        }
    }
}