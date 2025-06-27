import SwiftUI

extension Color {
    // Primary blue color for main elements (WCAG AA compliant)
    static let azulPrimary = Color(red: 0.15, green: 0.35, blue: 0.75)
    
    // Light blue background for secondary elements
    static let azulSecondary = Color(red: 0.92, green: 0.96, blue: 1.0)
    
    // Darker blue for accents and highlights (improved contrast)
    static let azulAccent = Color(red: 0.08, green: 0.25, blue: 0.65)
    
    // Card background color with subtle warmth
    static let azulCardBackground = Color(red: 0.95, green: 0.95, blue: 0.95)
    
    // Text colors with excellent contrast ratios
    static let azulTextPrimary = Color(red: 0.1, green: 0.1, blue: 0.1)
    static let azulTextSecondary = Color(red: 0.4, green: 0.4, blue: 0.45)
    
    // Additional theme colors for enhanced visual hierarchy
    static let azulShadow = Color.azulPrimary.opacity(0.08)
    static let azulBorder = Color.azulPrimary.opacity(0.12)

    // Loading text color
    static let azulLoadingText = Color(red: 0.75, green: 0.75, blue: 0.75)
}