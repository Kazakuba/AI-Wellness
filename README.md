# AI Wellness 🌱

A comprehensive mental wellness iOS application built with SwiftUI that combines AI-powered therapy, mindfulness exercises, journaling, and gamification to support users' mental health journey.

![SwiftUI](https://img.shields.io/badge/SwiftUI-iOS-blue)
![Firebase](https://img.shields.io/badge/Firebase-Authentication-orange)
![Google Gemini](https://img.shields.io/badge/Google-Gemini%20AI-4285F4)

## 📱 Features

### 1. **AI Chat Therapy** 💬
- **Gemini 2.0 Flash Integration**: Powered by Google's Gemini AI model for empathetic conversations
- **Multi-Chat Support**: Create and manage multiple therapy sessions with different contexts
- **Chat History**: Persistent conversation history with automatic title generation
- **Real-time Messaging**: Smooth, responsive chat interface with typing indicators
- **Context-Aware Responses**: AI maintains conversation context for meaningful therapeutic interactions

### 2. **Daily Affirmations** ✨
- **Topic-Based Affirmations**: Curated affirmations across multiple categories:
  - Self-Love & Confidence
  - Gratitude & Positivity
  - Motivation & Success
  - Mindfulness & Peace
  - Health & Wellness
  - Relationships & Connection
- **Clean Architecture**: Implements domain-driven design with use cases and repositories
- **History Tracking**: Save and review your favorite affirmations
- **Daily Reminders**: Get uplifting messages when you need them most

### 3. **Breathing Exercises** 🌬️
- **Multiple Techniques**: Various breathing patterns including:
  - Square Breathing (4-4-4-4)
  - 4-7-8 Technique
  - Box Breathing
  - Custom patterns
- **Visual Animations**: Beautiful, smooth animations guide your breathing rhythm
- **Theme Categories**: Customize your experience with different visual themes
- **Customization**: Adjust duration, animation size, and visual style
- **Progress Tracking**: Monitor your breathing practice sessions

### 4. **Personal Journal** 📔
- **Calendar View**: Visual calendar interface to track your journaling journey
- **Rich Writing Experience**: Distraction-free writing environment
- **Entry Management**: Create, edit, and review past entries
- **Time-Based Organization**: Entries organized by date for easy navigation

### 5. **Time Capsule** ⏰
- **Secret Feature**: Unlock by shaking your device from the dashboard!
- **Delayed Messages**: Write notes to your future self
- **Flexible Timeframes**: Choose when to unlock (1 month, 3 months, 6 months, or 1 year)
- **Smart Notifications**: Get notified when your time capsule unlocks
- **Archive System**: Review all your unlocked time capsules
- **Lottie Animations**: Delightful unlock animations create magical moments

### 6. **Gamification System** 🎮
- **XP & Leveling**: Earn experience points and level up as you progress
- **Achievements**: Unlock 7 unique achievements:
  - First Affirmation
  - Breathing Master
  - Journaling Hero
  - Hidden Time Capsule (shake to discover!)
  - First AI Chat
  - First Journal Entry
  - Time Capsule Creator
- **Progressive Badges**: 6 leveling badges with multiple milestones:
  - **Consistency** (Daily streaks: Bronze→Silver→Gold at 3, 7, 30 days)
  - **Affirmation Collector** (3, 20, 50 affirmations)
  - **Breathing Journey** (3, 15, 30 sessions)
  - **Journaling Journey** (3, 10, 30 entries)
  - **Time Capsule Journey** (3, 10, 20 capsules)
  - **AI Conversationalist** (3, 10, 20 chat sessions)
  - **Level Up!** (Reach levels 2, 5, 10)
- **Confetti Celebrations**: Visual rewards when unlocking achievements
- **Weekly Recap**: Track your weekly progress and streaks

### 7. **User Authentication** 🔐
- **Firebase Integration**: Secure authentication system
- **Google Sign-In**: Seamless OAuth integration
- **Email/Password**: Traditional authentication option
- **Persistent Sessions**: Stay logged in securely
- **Onboarding Flow**: First-time user experience walkthrough

### 8. **Settings & Customization** ⚙️
- **Dark Mode**: Full dark mode support with system integration
- **User Profile**: Manage your account information
- **Notification Management**: Control all app notifications
- **Support & About**: Access help and app information
- **Danger Zone**: Account management and data deletion options
- **Achievement Reset**: Developer tools for testing (if needed)

## 🏗️ Architecture

The application follows **Clean Architecture** principles with a modular, feature-based structure:

### Architectural Patterns

#### **1. MVVM (Model-View-ViewModel)**
The primary architectural pattern used throughout the app:
- **Models**: Data structures and business entities
- **Views**: SwiftUI views (presentation layer)
- **ViewModels**: Business logic, state management (`@ObservableObject`)

#### **2. Clean Architecture (Affirmations Module)**
Demonstrates domain-driven design:
- **Domain Layer**: Entities, use cases, repository interfaces
- **Data Layer**: Repository implementations, data sources
- **Presentation Layer**: ViewModels, Views
- **Benefits**: Testability, separation of concerns, scalability

#### **3. Service Layer Pattern**
Centralized services for cross-cutting concerns:
- `GeminiAPIService`: API communication
- `AuthenticationService`: User authentication
- `NotificationService`: Push notifications
- `PersistenceService`: Data storage
- `GamificationManager`: Shared gamification logic

#### **4. Singleton Pattern**
Used for shared managers:
- `GamificationManager.shared`
- `ConfettiManager.shared`
- `GeminiAPIService.shared`
- `PersistenceService.shared`

### Why This Structure?

#### **Feature-Based Modules**
Each major feature (AiChat, Affirmations, Breathing, etc.) is self-contained with its own:
- **Models**: Feature-specific data structures
- **ViewModels**: Business logic isolated to the feature
- **Views**: UI components
- **Services**: Feature-specific utilities

#### **Shared Components at Root Level**
- `Dashboard/`: Contains gamification logic used across all features
- `LocalNotifications/`: Notification infrastructure used by multiple modules
- `ConfettiManager.swift`: Visual feedback system accessible app-wide

#### **Data Persistence Strategy**
- **UserDefaults**: Simple key-value data (user preferences, gamification state)
- **File System**: Complex data structures (Time Capsule notes via `PersistenceService`)
- **Firebase**: User authentication and future cloud features

## 🔧 Technical Stack

### Frameworks & Libraries
- **SwiftUI**: Modern declarative UI framework
- **Firebase**: Authentication and backend services
- **Google Sign-In SDK**: OAuth integration
- **Combine**: Reactive programming and async operations
- **Lottie**: High-quality animations
- **ConfettiSwiftUI**: Celebration effects
- **UserNotifications**: Local notifications and scheduling

### APIs & Services
- **Google Gemini 2.0 Flash**: AI chat integration
- **Firebase Authentication**: User management
- **Local Notifications**: Time capsule reminders

### Design Patterns
- MVVM (Model-View-ViewModel)
- Clean Architecture (Affirmations)
- Repository Pattern
- Singleton Pattern
- Observer Pattern (Combine + @Published)
- Dependency Injection (@EnvironmentObject)

## 🚀 Getting Started

### Prerequisites
- Xcode 15.0+
- iOS 17.0+
- Swift 5.9+
- Firebase account
- Google Cloud account (for Gemini API)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/AI-Wellness.git
   cd AI-Wellness/AiWellness
   ```

2. **Configure Firebase**
   - Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Download `GoogleService-Info.plist`
   - Add it to the `AiWellness` folder in Xcode

3. **Set up Gemini API**
   - Get an API key from [Google AI Studio](https://makersuite.google.com/app/apikey)
   - Add to `Info.plist`:
     ```xml
     <key>GeminiAPIKey</key>
     <string>YOUR_API_KEY_HERE</string>
     ```
   - Or create a `.xcconfig` file (recommended for security)

4. **Install Dependencies**
   - Firebase SDK and Google Sign-In are managed via Swift Package Manager
   - Open the project in Xcode
   - Dependencies should resolve automatically

5. **Build and Run**
   - Select a simulator or physical device
   - Press `Cmd + R` to build and run

### Configuration Files

#### `Info.plist`
```xml
<key>GeminiAPIKey</key>
<string>YOUR_GEMINI_API_KEY</string>

<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>YOUR_REVERSED_CLIENT_ID</string>
        </array>
    </dict>
</array>
```

#### `AiWellness.entitlements`
Required for features like:
- Keychain sharing
- Push notifications
- Background modes

## 🎮 User Journey

1. **First Launch**: User sees onboarding flow explaining app features
2. **Authentication**: Sign in with Google or email/password
3. **Dashboard**: Central hub showing XP, level, achievements, and weekly recap
4. **Feature Exploration**: Navigate via bottom tab bar to different features
5. **Hidden Discovery**: Shake device on dashboard to unlock Time Capsule feature
6. **Progress Tracking**: Watch achievements unlock and badges level up
7. **Consistent Engagement**: Build streaks to maximize gamification rewards

## 🔒 Privacy & Security

- **Local-First**: Journal entries and time capsules stored locally on device
- **Secure Authentication**: Firebase handles auth with industry-standard security
- **API Key Protection**: Gemini API key stored securely in configuration files
- **No Data Selling**: User data is never shared or sold
- **Transparent Permissions**: Clear prompts for notifications and device features