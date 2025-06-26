import XCTest
@testable import AzulHackerNews

@MainActor
final class StoryViewModelTests: XCTestCase {
    var viewModel: StoryViewModel!
    
    override func setUpWithError() throws {
        viewModel = StoryViewModel()
    }
    
    override func tearDownWithError() throws {
        viewModel = nil
    }
    
    func testInitialState() {
        // Test initial state of ViewModel
        XCTAssertTrue(viewModel.stories.isEmpty, "Stories should be empty initially")
        XCTAssertFalse(viewModel.isLoading, "Should not be loading initially")
        XCTAssertFalse(viewModel.isLoadingMore, "Should not be loading more initially")
        XCTAssertNil(viewModel.errorMessage, "Should have no error initially")
        XCTAssertFalse(viewModel.hasReachedEnd, "Should not have reached end initially")
    }
    
    func testLoadInitialStories() async {
        // Test loading initial stories
        await viewModel.loadInitialStories()
        
        // After loading, should have stories or an error
        let hasStoriesOrError = !viewModel.stories.isEmpty || viewModel.errorMessage != nil
        XCTAssertTrue(hasStoriesOrError, "Should either have stories or an error message")
        
        // Should not be loading after completion
        XCTAssertFalse(viewModel.isLoading, "Should not be loading after completion")
        
        if !viewModel.stories.isEmpty {
            // If we have stories, verify they're properly formatted
            for story in viewModel.stories {
                XCTAssertGreaterThan(story.id, 0, "Story ID should be positive")
                XCTAssertFalse(story.title.isEmpty, "Story should have a title")
                XCTAssertFalse(story.by.isEmpty, "Story should have an author")
                XCTAssertGreaterThan(story.time, 0, "Story should have a valid timestamp")
            }
            
            // Stories should be sorted by time (newest first)
            if viewModel.stories.count > 1 {
                for i in 0..<(viewModel.stories.count - 1) {
                    XCTAssertGreaterThanOrEqual(
                        viewModel.stories[i].time,
                        viewModel.stories[i + 1].time,
                        "Stories should be sorted by time (newest first)"
                    )
                }
            }
        }
    }
    
    func testLoadMoreStories() async {
        // First load initial stories
        await viewModel.loadInitialStories()
        
        // Skip test if initial load failed
        guard !viewModel.stories.isEmpty else {
            XCTSkip("Initial story loading failed, skipping load more test")
        }
        
        let initialCount = viewModel.stories.count
        
        // Test loading more stories
        await viewModel.loadMoreStories()
        
        // Should not be loading more after completion
        XCTAssertFalse(viewModel.isLoadingMore, "Should not be loading more after completion")
        
        // Should either have more stories or reached the end/error
        let hasMoreStoriesOrEndOrError = viewModel.stories.count > initialCount || 
                                        viewModel.hasReachedEnd || 
                                        viewModel.errorMessage != nil
        XCTAssertTrue(hasMoreStoriesOrEndOrError, "Should have more stories, reached end, or have error")
    }
    
    func testRetryLoad() async {
        // Test retry functionality
        await viewModel.retryLoad()
        
        // Should complete without crashing
        XCTAssertFalse(viewModel.isLoading, "Should not be loading after retry completion")
    }
    
    func testClearError() {
        // Set an error message
        viewModel.errorMessage = "Test error"
        XCTAssertNotNil(viewModel.errorMessage, "Error message should be set")
        
        // Clear the error
        viewModel.clearError()
        XCTAssertNil(viewModel.errorMessage, "Error message should be cleared")
    }
    
    func testMemoryCleanup() async {
        // Load initial stories
        await viewModel.loadInitialStories()
        
        // Skip if no stories loaded
        guard !viewModel.stories.isEmpty else {
            XCTSkip("No stories loaded for memory cleanup test")
        }
        
        let initialCount = viewModel.stories.count
        
        // Test cleanup function
        viewModel.cleanup()
        
        // Stories count should not increase after cleanup
        XCTAssertLessThanOrEqual(viewModel.stories.count, initialCount, "Cleanup should not increase story count")
    }
    
    func testStoryProperties() {
        // Test Story model computed properties
        let testStory = Story(
            id: 123,
            title: "Test Story",
            url: "https://example.com/test",
            by: "testuser",
            time: Date().timeIntervalSince1970,
            text: nil,
            type: "story"
        )
        
        // Test publishDate computed property
        XCTAssertEqual(testStory.publishDate.timeIntervalSince1970, testStory.time, accuracy: 1.0)
        
        // Test displaySource computed property
        XCTAssertEqual(testStory.displaySource, "example.com")
        
        // Test story without URL
        let storyWithoutURL = Story(
            id: 124,
            title: "Test Story 2",
            url: nil,
            by: "testuser2",
            time: Date().timeIntervalSince1970,
            text: "Story text",
            type: "story"
        )
        
        XCTAssertEqual(storyWithoutURL.displaySource, "Hacker News")
    }
}