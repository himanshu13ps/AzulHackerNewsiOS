import SwiftUI
import SafariServices

struct CardView: View {
    let story: Story
    @State private var showingSafari = false
    @State private var isPressed = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Story title
            Text(story.title)
                .font(.system(.headline, design: .default))
                .foregroundColor(.azulTextPrimary)
                .lineLimit(nil) // Allow expansion for larger text sizes
                .multilineTextAlignment(.leading)
                .accessibilityAddTraits(.isHeader)
                .dynamicTypeSize(...DynamicTypeSize.accessibility3) // Limit extreme sizes
            
            // Story metadata row
            HStack {
                // Author
                Text("by \(story.by)")
                    .font(.system(.caption, design: .default))
                    .foregroundColor(.azulTextSecondary)
                    .accessibilityLabel("Author: \(story.by)")
                    .dynamicTypeSize(...DynamicTypeSize.accessibility2)
                
                Spacer()
                
                // Source/Domain
                Text(story.displaySource)
                    .font(.system(.caption, design: .default))
                    .foregroundColor(.azulAccent)
                    .fontWeight(.medium)
                    .accessibilityLabel("Source: \(story.displaySource)")
                    .dynamicTypeSize(...DynamicTypeSize.accessibility2)
            }
            
            // Publish date and score
            HStack {
                Image(systemName: "clock")
                    .foregroundColor(.azulTextSecondary)
                    .font(.caption)
                
                Text(story.relativeTimeString)
                    .font(.system(.caption, design: .default))
                    .foregroundColor(.azulTextSecondary)
                    .accessibilityLabel("Published \(story.relativeTimeString)")
                    .dynamicTypeSize(...DynamicTypeSize.accessibility2)
                
                Spacer()
                
                // Score
                if !story.scoreString.isEmpty {
                    Text(story.scoreString)
                        .font(.system(.caption, design: .default))
                        .foregroundColor(.azulTextSecondary)
                        .accessibilityLabel(story.scoreString)
                        .dynamicTypeSize(...DynamicTypeSize.accessibility2)
                }
            }
        }
        .padding(16)
        .background(Color.azulCardBackground)
        .cornerRadius(12)
        .shadow(
            color: Color.azulShadow,
            radius: 8,
            x: 0,
            y: 2
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.azulBorder, lineWidth: 1)
        )
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .onTapGesture {
            if let url = story.url, !url.isEmpty {
                showingSafari = true
            }
        }
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }, perform: {})
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Story: \(story.title)")
        .accessibilityHint(story.url != nil ? "Tap to open in Safari" : "Story details")
        .sheet(isPresented: $showingSafari) {
            if let url = story.url, let safariURL = URL(string: url) {
                SafariView(url: safariURL)
            }
        }
    }
}

#Preview {
    CardView(story: Story(
        id: 1,
        title: "Sample Hacker News Story Title That Might Be Long",
        url: "https://example.com/article",
        by: "username",
        time: Date().timeIntervalSince1970 - 3600, // 1 hour ago
        text: nil,
        type: "story",
        score: 42
    ))
    .padding()
    .background(Color.azulSecondary)
}

// Safari View Controller wrapper
struct SafariView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        let safariViewController = SFSafariViewController(url: url)
        safariViewController.preferredBarTintColor = UIColor(Color.azulPrimary)
        safariViewController.preferredControlTintColor = UIColor.white
        return safariViewController
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
        // No updates needed
    }
}