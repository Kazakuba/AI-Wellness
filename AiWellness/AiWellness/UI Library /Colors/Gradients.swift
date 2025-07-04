import SwiftUI

struct Gradients {
    static func mainBackground(isDarkMode: Bool) -> LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: isDarkMode ?
                               [Color.indigo, Color.black] :
                               [Color(red: 1.0, green: 0.85, blue: 0.75), Color(red: 1.0, green: 0.72, blue: 0.58)]
                             ),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    static func unlockButtonBackground(isDarkMode: Bool) -> LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: isDarkMode ?
                               [Color.indigo, Color.black] :
                               [Color(red: 1.0, green: 0.85, blue: 0.75), Color(red: 1.0, green: 0.72, blue: 0.58)]
                             ),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    static func unlockButtonBorder(isDarkMode: Bool) -> LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: isDarkMode ?
                               [Color.white.opacity(0.5), Color.indigo.opacity(0.3)] :
                               [Color.white.opacity(0.5), Color.orange.opacity(0.3)]
                             ),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    static func dashboardMainBackground(isDarkMode: Bool) -> LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: isDarkMode ?
                               [Color.indigo, Color.black] :
                               [Color(red: 1.0, green: 0.85, blue: 0.75), Color(red: 1.0, green: 0.72, blue: 0.58)]
                             ),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    static func dashboardCardBackground(isDarkMode: Bool, animate: Bool = false) -> LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: isDarkMode ?
                [Color.indigo.opacity(0.5), Color.black.opacity(0.5)] :
                [Color(red: 1.0, green: 0.6, blue: 0.4), Color(red: 1.0, green: 0.8, blue: 0.6)]
            ),
            startPoint: animate ? .topLeading : .topTrailing,
            endPoint: animate ? .bottomTrailing : .bottom
        )
    }
    
    static var dashboardFlameGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [Color.orange, Color.yellow, Color.red]),
            startPoint: .topLeading,
            endPoint: .bottom
        )
    }
    
    // MARK: - Breathing Gradients
    // Square Animation
    static func breathingSquareMainGradient() -> LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.blue.opacity(0.9),
                Color.cyan.opacity(0.7),
                Color.blue.opacity(0.5)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    static func breathingSquareStrokeGradient() -> LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.white.opacity(0.8),
                Color.cyan.opacity(0.6)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    // Circle Animation
    static func breathingCircleStrokeGradient() -> LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.white.opacity(0.8),
                Color.pink.opacity(0.6)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    // Triangle Animation
    static func breathingTriangleMainGradient() -> LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.green.opacity(0.9),
                Color.mint.opacity(0.7),
                Color.green.opacity(0.5)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
    static func breathingTriangleStrokeGradient() -> LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.white.opacity(0.8),
                Color.mint.opacity(0.6)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
    // Calm Animation
    static func breathingCalmStrokeGradient() -> LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.white.opacity(0.7),
                Color(red: 0.4, green: 0.7, blue: 0.9).opacity(0.5)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    // Energy Animation
    static func breathingEnergyStrokeGradient() -> LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.white.opacity(0.9),
                Color.yellow.opacity(0.7)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    static func breathingEnergyRayGradient() -> LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.orange.opacity(0.8),
                Color.yellow.opacity(0.6),
                Color.orange.opacity(0.3)
            ]),
            startPoint: .center,
            endPoint: .trailing
        )
    }
    // Focus Animation
    static func breathingFocusStrokeGradient() -> LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.white.opacity(0.8),
                Color(red: 0.8, green: 0.2, blue: 0.4).opacity(0.6)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    // Wave Animation
    static func breathingWaveGradient(opacity: Double) -> LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.teal.opacity(0.3 * opacity),
                Color.blue.opacity(0.2 * opacity),
                Color.clear
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
    static func breathingWaveStrokeGradient() -> LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.white.opacity(0.8),
                Color.cyan.opacity(0.6)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    // Spiral Animation
    static func breathingSpiralStrokeGradient(opacity: Double) -> LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.indigo.opacity(0.4 * opacity),
                Color.purple.opacity(0.2 * opacity),
                Color.clear
            ]),
            startPoint: .center,
            endPoint: .trailing
        )
    }
    static func breathingSpiralCircleStrokeGradient() -> LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.white.opacity(0.8),
                Color.purple.opacity(0.6)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // MARK: - AiChat Gradients
    static func aiChatMainBackground(isDarkMode: Bool) -> LinearGradient {
        dashboardMainBackground(isDarkMode: isDarkMode)
    }
    static func aiChatSectionBackground(isDarkMode: Bool, opacity: Double = 0.3) -> LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: isDarkMode ?
                [Color.white.opacity(opacity), Color.white.opacity(opacity - 0.1)] :
                [Color.white.opacity(opacity + 0.1), Color.white.opacity(opacity)]
            ),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    static var aiChatUserBubble: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    static var aiChatAIBubble: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [Color.green, Color.green.opacity(0.8)]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // MARK: - Onboarding Gradients
    static var onboardingPeachBackground: LinearGradient {
        LinearGradient(
            colors: [
                Color("onboardingGradient").opacity(0.1),
                Color("onboardingGradient2").opacity(0.15)
            ],
            startPoint: .topTrailing,
            endPoint: .bottom
        )
    }
    static func onboardingCardBackground(colorScheme: ColorScheme) -> LinearGradient {
        if colorScheme == .dark {
            return LinearGradient(
                colors: [
                    Color(.secondarySystemBackground).opacity(0.95),
                    ColorPalette.CustomPrimary.opacity(0.08)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        } else {
            return LinearGradient(
                colors: [
                    Color.white.opacity(0.95),
                    ColorPalette.CustomPrimary.opacity(0.1)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
    static func onboardingAnimatedOverlay(animateGradient: Bool) -> LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.purple.opacity(0.18),
                ColorPalette.CustomPrimary.opacity(0.12),
                Color.purple.opacity(0.18)
            ]),
            startPoint: animateGradient ? .topLeading : .bottomTrailing,
            endPoint: animateGradient ? .bottomTrailing : .topLeading
        )
    }
    static func onboardingMainBackground(colorScheme: ColorScheme) -> LinearGradient {
        if colorScheme == .dark {
            return LinearGradient(
                colors: [
                    ColorPalette.CustomPrimary.opacity(0.18),
                    ColorPalette.CustomSecondary.opacity(0.15),
                    Color(.systemBackground).opacity(0.95)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            return LinearGradient(
                colors: [
                    ColorPalette.CustomPrimary.opacity(0.15),
                    ColorPalette.CustomSecondary.opacity(0.1),
                    Color.white.opacity(0.8)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    static var onboardingButtonGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 0.63, green: 0.35, blue: 1.0),
                Color(red: 1.0, green: 0.65, blue: 0.4)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
} 
