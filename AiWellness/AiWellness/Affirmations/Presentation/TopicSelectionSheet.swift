// Topic selection bottom sheet UI
import SwiftUI

struct TopicSelectionSheet: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var isPresented: Bool
    @Binding var selectedTopic: AffirmationTopic?
    let topics: [AffirmationTopic]
    var onSelect: (AffirmationTopic) -> Void
    
    @State private var searchText = ""
    
    var filteredTopics: [AffirmationTopic] {
        if searchText.isEmpty { return topics }
        return topics.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Text("Categories")
                        .font(.title2).bold()
                    Spacer()
                }
                .padding(.vertical, 8)
                
                TextField("Search", text: $searchText)
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
                
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                        ForEach(filteredTopics) { topic in
                            TopicCardView(topic: topic, isSelected: selectedTopic?.id == topic.id, colorScheme: colorScheme) {
                                selectedTopic = topic
                                onSelect(topic)
                                isPresented = false
                            }
                        }
                    }
                    .padding()
                }
                Spacer()
            }
            .background(colorScheme == .dark ? Color(.black) : Color(.white))
        }
    }
}

struct TopicCardView: View {
    let topic: AffirmationTopic
    let isSelected: Bool
    let colorScheme: ColorScheme
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color(.systemGray6))
                    .frame(height: 120)
                    .overlay(
                        VStack(spacing: 10) {
                            Image(systemName: topic.iconName)
                                .font(.system(size: 36))
                                .foregroundColor(Color.primary)
                            Text(topic.title)
                                .font(.headline)
                                .foregroundColor(Color.primary)
                        }
                    )
                    .overlay(
                        Group {
                            if isSelected {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(Color.accentColor)
                                    .offset(x: -8, y: 8)
                            }
                        }, alignment: .topTrailing
                    )
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}
