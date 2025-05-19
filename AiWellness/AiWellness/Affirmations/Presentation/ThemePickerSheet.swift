import SwiftUI

struct ThemePickerSheet: View {
    @Binding var isPresented: Bool
    @AppStorage("selectedThemeId") private var selectedThemeId: String = ThemeLibrary.defaultTheme.id
    @State private var selectedCategory: Theme.Category = .all
    @State private var tempSelectedThemeId: String = ThemeLibrary.defaultTheme.id
    let themes = ThemeLibrary.allThemes
    var filteredThemes: [Theme] {
        selectedCategory == .all ? themes : themes.filter { $0.category == selectedCategory }
    }
    public init(isPresented: Binding<Bool>) {
        self._isPresented = isPresented
        // tempSelectedThemeId will be set in .onAppear
    }
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Themes")
                    .font(.largeTitle).bold()
                    .padding(.top, 16)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(Theme.Category.allCases) { cat in
                            Button(action: { selectedCategory = cat }) {
                                Text(cat.rawValue)
                                    .font(.subheadline)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(selectedCategory == cat ? Color.blue.opacity(0.2) : Color.white)
                                    .foregroundColor(selectedCategory == cat ? .blue : .primary)
                                    .cornerRadius(16)
                            }
                        }
                    }
                    .padding(.horizontal, 8)
                }
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(filteredThemes) { theme in
                            ZStack(alignment: .bottom) {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(theme.gradient)
                                    .frame(width: 140, height: 200)
                                    .overlay(
                                        Text(theme.name)
                                            .font(.headline)
                                            .foregroundColor(.white)
                                            .padding(.bottom, 16), alignment: .bottom
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(tempSelectedThemeId == theme.id ? Color.blue : Color.clear, lineWidth: 4)
                                    )
                                    .onTapGesture {
                                        tempSelectedThemeId = theme.id
                                    }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
                Spacer()
                Button(action: {
                    selectedThemeId = tempSelectedThemeId
                    isPresented = false
                }) {
                    Text("Apply Theme")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                }
                .padding(.bottom, 24)
            }
            .padding(.horizontal, 8)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { isPresented = false }
                }
            }
        }
        .onAppear {
            tempSelectedThemeId = selectedThemeId
        }
    }
}
