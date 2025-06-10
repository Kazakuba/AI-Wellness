import SwiftUI

struct CollapsibleSectionView<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    @State private var isExpanded: Bool = false
    var body: some View {
        VStack(spacing: 0) {
            Button(action: { withAnimation { isExpanded.toggle() } }) {
                HStack {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemBackground).opacity(0.7))
                )
            }
            if isExpanded {
                content
                    .padding([.horizontal, .bottom])
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
}

#Preview {
    CollapsibleSectionView(title: "Section") {
        Text("Content goes here")
    }
}
