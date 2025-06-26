import SwiftUI

// Shared feature icon
public func featureIcon(_ systemName: String, _ label: String) -> some View {
    VStack(spacing: 8) {
        Image(systemName: systemName)
            .resizable()
            .scaledToFit()
            .frame(width: 40, height: 40)
            .foregroundColor(Color.accentColor.opacity(0.85))
            .shadow(color: Color.accentColor.opacity(0.18), radius: 4, x: 0, y: 2)
        Text(label)
            .font(.subheadline)
            .foregroundColor(.primary)
    }
    .frame(width: 90)
}

// Shared benefit row
public func benefitRow(_ systemName: String, _ text: String) -> some View {
    HStack(spacing: 16) {
        Image(systemName: systemName)
            .foregroundColor(.accentColor)
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
                        .fill(isSelected ? Color.accentColor.opacity(0.18) : Color.accentColor.opacity(0.08))
                        .frame(width: 40, height: 40)
                    Image(systemName: icon)
                        .foregroundColor(isSelected ? Color.accentColor : Color.accentColor.opacity(0.5))
                        .scaleEffect(isSelected ? 1.2 : 1.0)
                        .animation(.spring(), value: isSelected)
                }
                Text(label)
                    .font(.body)
                    .foregroundColor(.primary)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.accentColor)
                        .transition(.scale)
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.accentColor : Color.accentColor.opacity(0.3), lineWidth: 2)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.7))
                    )
            )
            .shadow(color: isSelected ? Color.accentColor.opacity(0.12) : Color.clear, radius: 6, x: 0, y: 2)
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
                    .fill(configuration.isOn ? Color.accentColor : Color.gray.opacity(0.3))
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
        .padding(.vertical, 4)
    }
} 