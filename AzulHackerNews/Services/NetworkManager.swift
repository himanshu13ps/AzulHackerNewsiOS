import Foundation

enum StoryType {
  case top
  case new
}

enum NetworkError: Error, LocalizedError {
  case invalidURL
  case noData
  case decodingError
  case networkError(Error)

  var errorDescription: String? {
    switch self {
    case .invalidURL:
      return "Invalid URL"
    case .noData:
      return "No data received"
    case .decodingError:
      return "Failed to decode response"
    case .networkError(let error):
      return "Network error: \(error.localizedDescription)"
    }
  }
}

class NetworkManager: ObservableObject {
  private let baseURL = "https://hacker-news.firebaseio.com/v0"
  private let session: URLSession

  init() {
    // Configure URLSession for better performance
    let config = URLSessionConfiguration.default
    config.requestCachePolicy = .reloadIgnoringLocalCacheData
    config.timeoutIntervalForRequest = 10.0
    config.timeoutIntervalForResource = 30.0
    config.httpMaximumConnectionsPerHost = 6
    self.session = URLSession(configuration: config)
  }

  // Fetch array of top story IDs
  func fetchTopStoryIds() async throws -> [Int] {
    guard let url = URL(string: "\(baseURL)/topstories.json") else {
      throw NetworkError.invalidURL
    }

    do {
      let (data, _) = try await session.data(from: url)
      let storyIds = try JSONDecoder().decode([Int].self, from: data)
      return storyIds
    } catch {
      if error is DecodingError {
        throw NetworkError.decodingError
      } else {
        throw NetworkError.networkError(error)
      }
    }
  }

  // Fetch array of new story IDs
  func fetchNewStoryIds() async throws -> [Int] {
    guard let url = URL(string: "\(baseURL)/newstories.json") else {
      throw NetworkError.invalidURL
    }

    do {
      let (data, _) = try await session.data(from: url)
      let storyIds = try JSONDecoder().decode([Int].self, from: data)
      return storyIds
    } catch {
      if error is DecodingError {
        throw NetworkError.decodingError
      } else {
        throw NetworkError.networkError(error)
      }
    }
  }

  // Fetch story IDs based on story type
  func fetchStoryIds(for type: StoryType) async throws -> [Int] {
    switch type {
    case .top:
      return try await fetchTopStoryIds()
    case .new:
      return try await fetchNewStoryIds()
    }
  }

  // Fetch individual story by ID
  func fetchStory(id: Int) async throws -> Story {
    guard let url = URL(string: "\(baseURL)/item/\(id).json") else {
      throw NetworkError.invalidURL
    }

    do {
      let (data, _) = try await session.data(from: url)
      let story = try JSONDecoder().decode(Story.self, from: data)
      return story
    } catch {
      if error is DecodingError {
        throw NetworkError.decodingError
      } else {
        throw NetworkError.networkError(error)
      }
    }
  }

  // Fetch multiple stories concurrently with throttling
  func fetchStories(ids: [Int]) async throws -> [Story] {
    // Limit concurrent requests to prevent overwhelming the API
    let maxConcurrentRequests = 10
    let chunks = ids.chunked(into: maxConcurrentRequests)
    var allStories: [Story] = []

    for chunk in chunks {
      let chunkStories = try await withThrowingTaskGroup(of: Story?.self) { group in
        var stories: [Story] = []

        for id in chunk {
          group.addTask {
            do {
              return try await self.fetchStory(id: id)
            } catch {
              // Log error but don't fail the entire batch
              print("Failed to fetch story \(id): \(error)")
              return nil
            }
          }
        }

        for try await story in group {
          if let story = story {
            stories.append(story)
          }
        }

        return stories
      }

      allStories.append(contentsOf: chunkStories)
    }

    return allStories
  }
}

// Array extension for chunking
extension Array {
  func chunked(into size: Int) -> [[Element]] {
    return stride(from: 0, to: count, by: size).map {
      Array(self[$0..<Swift.min($0 + size, count)])
    }
  }
}
