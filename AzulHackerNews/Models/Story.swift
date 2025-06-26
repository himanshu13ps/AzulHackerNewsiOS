import Foundation

struct Story: Codable, Identifiable {
    let id: Int
    let title: String
    let url: String?
    let by: String
    let time: TimeInterval
    let text: String?
    let type: String
    
    // Computed property for formatted date
    var publishDate: Date {
        Date(timeIntervalSince1970: time)
    }
    
    // Computed property for display URL or description
    var displaySource: String {
        if let url = url, let host = URL(string: url)?.host {
            return host
        }
        return "Hacker News"
    }
}