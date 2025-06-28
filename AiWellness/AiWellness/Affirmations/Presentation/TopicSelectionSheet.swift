// Topic selection bottom sheet UI
import SwiftUI

struct TopicSelectionSheet: View {
    @Binding var isPresented: Bool
    @Binding var selectedTopic: AffirmationTopic?
    let topics: [AffirmationTopic]
    var onSelect: (AffirmationTopic) -> Void
    
    @State private var searchText = ""
    @AppStorage("isDarkMode") var isDarkMode: Bool = false
    
    var filteredTopics: [AffirmationTopic] {
        if searchText.isEmpty { return topics }
        return topics.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                HStack {
                    Button("Cancel") { isPresented = false }
                        .font(.headline)
                        .padding(.leading)
                    Spacer()
                    Text("Categories")
                        .font(.title2).bold()
                    Spacer()
                    Button("Unlock all") { /* Unlock logic */ }
                        .font(.headline)
                        .padding(.trailing)
                }
                .padding(.vertical, 8)
                
                TextField("Search", text: $searchText)
                    .padding(10)
                    .background(Color.customSystemGray6)
                    .cornerRadius(10)
                    .padding(.horizontal)
                
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                        ForEach(filteredTopics) { topic in
                            TopicCardView(topic: topic, isSelected: selectedTopic?.id == topic.id) {
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
            .background(Color(.systemGray2))
        }
    }
}

struct TopicCardView: View {
    let topic: AffirmationTopic
    let isSelected: Bool
    let onTap: () -> Void
    @AppStorage("isDarkMode") var isDarkMode: Bool = false
    
    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.customSystemGray6)
                    .frame(height: 120)
                    .overlay(
                        VStack(spacing: 10) {
                            Image(systemName: topic.iconName)
                                .font(.system(size: 36))
                                .foregroundColor(isDarkMode ? .white : .black)
                            Text(topic.title)
                                .font(.headline)
                                .foregroundColor(isDarkMode ? .white : .black)
                        }
                    )
                    .overlay(
                        Group {
                            if isSelected {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(isDarkMode ? .white : .black)
                                    .offset(x: -8, y: 8)
                            }
                        }, alignment: .topTrailing
                    )
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}
