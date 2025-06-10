import SwiftUI

struct BadgesView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Visual rewards that evolve over time and XP level.")
                .font(.subheadline)
                .foregroundColor(.secondary)
            // TODO: List badges dynamically
            ForEach(0..<3) { i in
                HStack {
                    Image(systemName: "rosette")
                        .foregroundColor(.blue)
                    Text("Badge #\(i+1)")
                        .font(.body)
                }
            }
        }
        .padding(.vertical)
    }
}
