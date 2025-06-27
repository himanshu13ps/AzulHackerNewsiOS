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

  // Computed property for custom relative time formatting
  var relativeTimeString: String {
    let now = Date()
    let publishDate = Date(timeIntervalSince1970: time)
    let timeInterval = now.timeIntervalSince(publishDate)

    // Convert to minutes
    let minutes = Int(ceil(timeInterval / 60.0))

    if minutes < 60 {
      // Less than 60 minutes - show in minutes
      if minutes <= 1 {
        return "1 minute ago"
      } else {
        return "\(minutes) minutes ago"
      }
    } else if minutes < 1440 {  // Less than 24 hours (24 * 60 = 1440 minutes)
      // Less than 24 hours - show in hours
      let hours = Int(ceil(Double(minutes) / 60.0))
      if hours == 1 {
        return "1 hour ago"
      } else {
        return "\(hours) hours ago"
      }
    } else {
      // 24 hours or more - show in days
      let days = Int(ceil(Double(minutes) / 1440.0))
      if days == 1 {
        return "1 day ago"
      } else {
        return "\(days) days ago"
      }
    }
  }
}
