import Foundation
import SwiftUI

@MainActor
class StoryViewModel: ObservableObject {
    @Published var stories: [Story] = []
    @Published var isLoading: Bool = false
    @Published var isLoadingMore: Bool = false
    @Published var errorMessage: String?
    @Published var hasReachedEnd: Bool = false
    
    private let networkManager = NetworkManager()
    private var allStoryIds: [Int] = []
    private var currentPage: Int = 0
    private let pageSize: Int = 20
    private let maxStoriesInMemory: Int = 500 // Limit memory usage
    
    // Load initial stories (first 20)
    func loadInitialStories() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Fetch all story IDs first
            allStoryIds = try await networkManager.fetchNewStoryIds()
            
            // Reset pagination
            currentPage = 0
            stories = []
            hasReachedEnd = false
            
            // Load first page
            await loadMoreStories()
            
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // Load more stories for pagination
    func loadMoreStories() async {
        // Don't load if already loading or reached end
        guard !isLoadingMore && !hasReachedEnd else { return }
        
        isLoadingMore = true
        // Clear any previous error when starting a new load
        if errorMessage != nil {
            errorMessage = nil
        }
        
        do {
            let startIndex = currentPage * pageSize
            let endIndex = min(startIndex + pageSize, allStoryIds.count)
            
            // Check if we've reached the end
            if startIndex >= allStoryIds.count {
                hasReachedEnd = true
                isLoadingMore = false
                return
            }
            
            // Get IDs for current page
            let pageIds = Array(allStoryIds[startIndex..<endIndex])
            
            // Fetch stories for this page
            let newStories = try await networkManager.fetchStories(ids: pageIds)
            
            // Only proceed if we got some stories
            if !newStories.isEmpty {
                // Sort by time (newest first) and append to existing stories
                let sortedNewStories = newStories.sorted { $0.time > $1.time }
                stories.append(contentsOf: sortedNewStories)
                
                // Memory management: limit total stories in memory
                if stories.count > maxStoriesInMemory {
                    let excessCount = stories.count - maxStoriesInMemory
                    stories.removeFirst(excessCount)
                }
                
                // Update pagination
                currentPage += 1
            }
            
            // Check if we've reached the end
            if endIndex >= allStoryIds.count {
                hasReachedEnd = true
            }
            
        } catch {
            // For pagination errors, don't clear existing stories
            errorMessage = error.localizedDescription
        }
        
        isLoadingMore = false
    }
    
    // Retry loading after an error
    func retryLoad() async {
        if stories.isEmpty {
            await loadInitialStories()
        } else {
            await loadMoreStories()
        }
    }
    
    // Clear error message
    func clearError() {
        errorMessage = nil
    }
    
    // Memory management function
    private func optimizeMemoryUsage() {
        // Remove excess stories if we have too many
        if stories.count > maxStoriesInMemory {
            let excessCount = stories.count - maxStoriesInMemory
            stories.removeFirst(excessCount)
        }
    }
    
    // Cleanup function for memory management
    func cleanup() {
        optimizeMemoryUsage()
    }
}