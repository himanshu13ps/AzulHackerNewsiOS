import SwiftUI

struct AppIconView: View {
    var body: some View {
        ZStack {
            // Background gradient matching app theme
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.azulAccent,      // Top-leading corner (darker blue)
                    Color.azulPrimary,     // Middle (primary blue)
                    Color.azulSecondary    // Bottom-trailing corner (light blue)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Main content
            VStack(spacing: 8) {
                // "HN" monogram
                Text("AZUL")
                    .font(.system(size: 300, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 4, x: 2, y: 2)
                
                // Subtitle
                Text("Hacker News")
                    .font(.system(size: 125, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
                    .tracking(4)
                    .shadow(color: .black.opacity(0.2), radius: 2, x: 1, y: 1)
            }
            
            // Decorative elements
            Circle()
                .fill(Color.white.opacity(0.1))
                .frame(width: 300, height: 300)
                .offset(x: -80, y: -80)
                .blur(radius: 2)
            
            Circle()
                .fill(Color.white.opacity(0.05))
                .frame(width: 150, height: 150)
                .offset(x: 70, y: 90)
                .blur(radius: 1)
        }
        .frame(width: 1024, height: 1024)
        .clipShape(RoundedRectangle(cornerRadius: 180)) // iOS app icon corner radius
    }
}

// Dark mode variant
struct AppIconDarkView: View {
    var body: some View {
        ZStack {
            // Darker gradient for dark mode
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.05, green: 0.15, blue: 0.45), // Darker blue
                    Color(red: 0.08, green: 0.25, blue: 0.65), // Azul accent
                    Color(red: 0.12, green: 0.30, blue: 0.70)  // Slightly lighter
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Main content
            VStack(spacing: 8) {
                // "HN" monogram
                Text("AZUL")
                    .font(.system(size: 300, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.5), radius: 6, x: 3, y: 3)
                
                // Subtitle
                Text("Hacker News")
                    .font(.system(size: 125, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.95))
                    .tracking(4)
                    .shadow(color: .black.opacity(0.3), radius: 3, x: 2, y: 2)
            }
            
            // Decorative elements
            Circle()
                .fill(Color.white.opacity(0.08))
                .frame(width: 300, height: 300)
                .offset(x: -80, y: -80)
                .blur(radius: 2)
            
            Circle()
                .fill(Color.white.opacity(0.04))
                .frame(width: 150, height: 150)
                .offset(x: 70, y: 90)
                .blur(radius: 1)
        }
        .frame(width: 1024, height: 1024)
        .clipShape(RoundedRectangle(cornerRadius: 180))
    }
}

// Tinted variant (monochrome for iOS 18+)
struct AppIconTintedView: View {
    var body: some View {
        ZStack {
            // Single color background for tinting
            Color.primary
            
            // Main content
            VStack(spacing: 8) {
                // "HN" monogram
                Text("AZUL")
                    .font(.system(size: 300, weight: .bold, design: .rounded))
                    .foregroundColor(.azulSecondary)
                    .opacity(0.9)
                
                // Subtitle
                Text("Hacker News")
                    .font(.system(size: 125, weight: .medium, design: .rounded))
                    .foregroundColor(.azulSecondary)
                    .opacity(0.7)
                    .tracking(4)
            }
        }
        .frame(width: 1024, height: 1024)
        .clipShape(RoundedRectangle(cornerRadius: 180))
    }
}

// Preview for testing
#Preview("Standard Icon") {
    AppIconView()
        .frame(width: 200, height: 200)
}

#Preview("Dark Icon") {
    AppIconDarkView()
        .frame(width: 200, height: 200)
        .preferredColorScheme(.dark)
}

#Preview("Tinted Icon") {
    AppIconTintedView()
        .frame(width: 200, height: 200)
}
