import SwiftUI

// MARK: - Gradient Styles
struct OnboardingGradients {
    static let peachBackground = LinearGradient(
        colors: [
            Color("onboardingGradient").opacity(0.1),
            Color("onboardingGradient2").opacity(0.15)
        ],
        startPoint: .topTrailing,
        endPoint: .bottom
    )
    
    static func cardBackground(for colorScheme: ColorScheme) -> LinearGradient {
        if colorScheme == .dark {
            return LinearGradient(
                colors: [
                    Color(.secondarySystemBackground).opacity(0.95),
                    Color("CustomPrimary").opacity(0.08)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        } else {
            return LinearGradient(
                colors: [
                    Color.white.opacity(0.95),
                    Color("CustomPrimary").opacity(0.1)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
}

// Shared feature icon
public func featureIcon(_ systemName: String, _ label: String) -> some View {
    VStack(spacing: 8) {
        Image(systemName: systemName)
            .resizable()
            .scaledToFit()
            .frame(width: 40, height: 40)
            .foregroundColor(Color("CustomPrimary"))
            .shadow(color: Color("CustomPrimary").opacity(0.3), radius: 4, x: 0, y: 2)
        Text(label)
            .font(.subheadline)
            .foregroundColor(.primary)
    }
    .frame(width: 90)
}

// Shared benefit row
public func benefitRow(_ systemName: String, _ text: String) -> some View {
    HStack(spacing: 16) {
        ZStack {
            Circle()
                .fill(Color("CustomPrimary").opacity(0.15))
                .frame(width: 36, height: 36)
            Image(systemName: systemName)
                .foregroundColor(Color("CustomPrimary"))
        }
        Text(text)
            .font(.body)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
}

// Shared goal toggle
public struct GoalToggle: View {
    public let icon: String
    public let label: String
    public let isSelected: Bool
    public let onTap: () -> Void
    
    public init(icon: String, label: String, isSelected: Bool, onTap: @escaping () -> Void) {
        self.icon = icon
        self.label = label
        self.isSelected = isSelected
        self.onTap = onTap
    }
    
    public var body: some View {
        Button(action: onTap) {
            HStack {
                ZStack {
                    Circle()
                        .fill(isSelected ? Color("CustomPrimary").opacity(0.2) : Color("CustomSecondary").opacity(0.1))
                        .frame(width: 40, height: 40)
                    Image(systemName: icon)
                        .foregroundColor(isSelected ? Color("CustomPrimary") : Color("CustomSecondary"))
                        .scaleEffect(isSelected ? 1.2 : 1.0)
                        .animation(.spring(), value: isSelected)
                }
                Text(label)
                    .font(.body)
                    .foregroundColor(.primary)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color("CustomPrimary"))
                        .transition(.scale)
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color("CustomPrimary") : Color("CustomSecondary").opacity(0.3), lineWidth: 2)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(OnboardingGradients.cardBackground(for: .light))
                    )
            )
            .shadow(color: isSelected ? Color("CustomPrimary").opacity(0.15) : Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Shared colored toggle style
public struct ColoredToggleStyle: ToggleStyle {
    public init() {}
    public func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            Spacer()
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(configuration.isOn ? Color("CustomPrimary") : Color.gray.opacity(0.3))
                    .frame(width: 48, height: 28)
                Circle()
                    .fill(Color.white)
                    .frame(width: 24, height: 24)
                    .offset(x: configuration.isOn ? 10 : -10)
                    .shadow(color: .black.opacity(0.08), radius: 1, x: 0, y: 1)
                    .animation(.easeInOut(duration: 0.2), value: configuration.isOn)
            }
            .onTapGesture { configuration.isOn.toggle() }
        }
    }
}
