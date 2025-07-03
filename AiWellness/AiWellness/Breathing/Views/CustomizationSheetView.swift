import SwiftUI

// Customization sheet view
struct CustomizationSheetView: View {
    @ObservedObject var viewModel: BreathingExerciseViewModel
    @Environment(\.dismiss) private var dismiss
    var onStart: () -> Void
    
    @State private var selectedCategory = "All"
    @State private var filteredAnimations: [String] = []
    
    private let categories = ["All", "Stress Relief", "Sleep", "Energy", "Focus", "Beginner"]
    private let durations = [60.0, 180.0, 300.0, 600.0]
    
    @AppStorage("isDarkMode") var isDarkMode: Bool = false
    
    init(viewModel: BreathingExerciseViewModel, onStart: @escaping () -> Void) {
        self.viewModel = viewModel
        self.onStart = onStart
        self._filteredAnimations = State(initialValue: viewModel.animationTypes)
    }
    
    var body: some View {
        NavigationView {
            customizationContent
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("Breathing Exercises")
                            .font(.title.bold())
                            .foregroundColor(isDarkMode ? .white : .black)
                    }
                }
                .navigationBarItems(
                    leading: Button(action: { 
                        NotificationCenter.default.post(name: NSNotification.Name("DismissBreathingExercise"), object: nil)
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .foregroundColor(isDarkMode ? .white : .black)
                    },
                    trailing: Button("Start") {
                        onStart()
                        dismiss()
                    }
                    .font(Typography.Font.button)
                )
        }
        .accentColor(isDarkMode ? .white : .black)
        .background(
            (isDarkMode ? LinearGradient(gradient: Gradient(colors: [Color.indigo, Color.black]), startPoint: .topLeading, endPoint: .bottomTrailing) : LinearGradient(gradient: Gradient(colors: [Color(red: 1.0, green: 0.85, blue: 0.75), Color(red: 1.0, green: 0.72, blue: 0.58)]), startPoint: .topLeading, endPoint: .bottomTrailing))
                .edgesIgnoringSafeArea(.all)
        )
        .presentationBackground(
            isDarkMode ? LinearGradient(gradient: Gradient(colors: [Color.indigo, Color.black]), startPoint: .topLeading, endPoint: .bottomTrailing) : LinearGradient(gradient: Gradient(colors: [Color(red: 1.0, green: 0.85, blue: 0.75), Color(red: 1.0, green: 0.72, blue: 0.58)]), startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .onAppear {
            filteredAnimations = viewModel.getThemesForCategory(selectedCategory)
        }
        .onDisappear {
            print("DEBUG: CustomizationSheetView disappeared")
        }
    }
    
    private var customizationContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 30) {
                categorySelector
                
                Text("Select Theme")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(isDarkMode ? .white : .black)
                    .padding(.horizontal)
                
                themeGrid
                
                Text("Exercise Duration")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(isDarkMode ? .white : .black)
                    .padding(.horizontal)
                    .padding(.top)
                
                durationSelector
                
                Spacer(minLength: 40)
            }
            .padding(.bottom, 30)
        }
    }
    
    private var categorySelector: some View {
        VStack(alignment: .leading, spacing: 16) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(categories, id: \.self) { category in
                        Button(action: {
                            selectedCategory = category
                            filteredAnimations = viewModel.getThemesForCategory(category)
                        }) {
                            Text(category)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(
                                    selectedCategory == category ?
                                        (isDarkMode ? .white : .white) :
                                        (isDarkMode ? .black : .black)
                                )
                                .padding(.horizontal, 22)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 25)
                                        .fill(
                                            selectedCategory == category ?
                                                (isDarkMode ? Color.indigo : Color.black) :
                                                Color.white
                                        )
                                )
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private var themeGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            ForEach(filteredAnimations, id: \.self) { animation in
                themeCard(for: animation)
            }
        }
        .padding(.horizontal)
        .animation(.easeInOut, value: filteredAnimations)
    }
    
    private func themeCard(for animation: String) -> some View {
        Button(action: {
            viewModel.setAnimationForType(animation)
        }) {
            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(
                                colors: [
                                    viewModel.getColorForType(type: animation).opacity(0.6),
                                    viewModel.getColorForType(type: animation).opacity(0.3)
                                ]
                            ),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                viewModel.selectedAnimation == animation ? 
                                viewModel.getColorForType(type: animation) : Color.clear,
                                lineWidth: 2
                            )
                    )
                
                VStack {
                    Spacer()
                    
                    Image(systemName: viewModel.getAnimationIconName(for: animation))
                        .font(.system(size: 36))
                        .foregroundColor(.white.opacity(0.8))
                        .frame(maxWidth: .infinity)
                        .padding(.top, 20)
                    
                    Spacer()
                    
                    HStack {
                        Text(animation)
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(.white)
                            .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 1)
                            .padding(.leading, 16)
                            .padding(.bottom, 16)
                        
                        Spacer()
                    }
                }
                
                if viewModel.selectedAnimation == animation {
                    VStack {
                        HStack {
                            Spacer()
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                                .padding(12)
                        }
                        Spacer()
                    }
                }
            }
            .frame(height: 150)
        }
    }
    
    private var durationSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 15) {
                ForEach(durations, id: \.self) { duration in
                    Button(action: {
                        viewModel.setDuration(duration)
                    }) {
                        Text(formatDuration(duration))
                            .font(.system(size: 16, weight: .medium))
                            .padding(.vertical, 12)
                            .padding(.horizontal, 20)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(viewModel.totalDuration == duration ? ColorPalette.CustomPrimary : Color.white)
                            )
                            .foregroundColor(viewModel.totalDuration == duration ? .white : .black)
                            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    private func formatDuration(_ seconds: Double) -> String {
        if seconds < 60 {
            return "\(Int(seconds)) sec"
        } else {
            let minutes = Int(seconds) / 60
            return "\(minutes) min"
        }
    }
}
