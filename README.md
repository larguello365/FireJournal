# FireJournal

A modern, feature-rich iOS journaling application built with SwiftUI and Firebase, designed to capture and organize life's moments with intelligent tagging, photo metadata extraction, and seamless cross-app sharing capabilities.

## Overview

FireJournal is a sophisticated iOS application that demonstrates proficiency in modern iOS development practices, cloud integration, and user-centric design. Built entirely with SwiftUI, the app leverages Firebase for authentication and real-time data synchronization, while incorporating advanced iOS features like Share Extensions and Vision framework for intelligent content management.

## Key Features

### Core Functionality
- **Secure Authentication**: Full authentication flow with Firebase Auth including sign-up, sign-in, password reset, and secure session management
- **Real-time Sync**: Cloud-based journal entries synchronized across devices using Firebase Firestore
- **Photo Management**: Seamless photo selection from device library with automatic upload to Firebase Storage
- **Rich Text Entries**: Create detailed journal entries with captions and photo attachments

### Other Features
- **EXIF Metadata Extraction**: Automatically extracts and stores photo metadata including:
  - GPS location coordinates (latitude/longitude)
  - Original capture date and time
  - Smart location-based journaling capabilities

- **Intelligent Tagging System**:
  - Manual hashtag parsing from captions
  - Automatic image classification using Vision framework's ML models
  - Smart content categorization with confidence thresholds

- **Share Extension**: Native iOS Share Extension allowing users to quickly add journal entries from any app:
  - Share photos directly from Photos app or Safari
  - Add captions on-the-fly
  - Secure authentication handling in extension context
  - Background image upload and processing

### User Experience
- **Advanced Search**: Multi-faceted search functionality across:
  - Entry captions
  - Creation dates
  - User-defined tags
  - Auto-generated tags

- **Favorites System**: Quick access to important entries
- **Swipe-to-Delete**: Native iOS deletion gestures with Firestore cleanup
- **Custom Navigation Styling**: Branded purple navigation bars with dark mode support

## Technical Architecture

### Technology Stack
- **SwiftUI**: 100% SwiftUI implementation for modern, declarative UI
- **Firebase Suite**:
  - Firebase Auth for authentication
  - Cloud Firestore for NoSQL database
  - Firebase Storage for image hosting
- **Vision Framework**: Core ML integration for on-device image classification
- **PhotosUI**: Modern photo picker implementation
- **App Groups**: Secure credential sharing between main app and extension

### Architecture Highlights
- **MVVM Pattern**: Observable view models with `@Observable` and `@Environment`
- **Property Wrappers**: Custom `@FirestoreQuery` for reactive data fetching
- **Async/Await**: Modern concurrency for network operations
- **Type Safety**: Codable models for Firebase integration
- **Error Handling**: Comprehensive error management across all operations

### Code Quality
- **Modular Design**: Clean separation of concerns with dedicated authentication, models, and views
- **Reusable Components**: Custom views like `EntryRow` and `StorageImageView`
- **Modern Swift**: Leveraging latest Swift features including structured concurrency
- **Memory Management**: Efficient image handling and caching strategies

## Project Structure

```
FireJournal/
├── FireJournal/
│   ├── Authentication/
│   │   ├── AuthController.swift    # Authentication state management
│   │   └── AuthView.swift         # Login/signup UI
│   ├── Models/
│   │   └── Entry.swift            # Core data model
│   ├── Views/
│   │   ├── JournalView.swift      # Main journal list
│   │   ├── AddEntryView.swift     # Entry creation with ML
│   │   ├── EditEntryView.swift    # Entry modification
│   │   ├── EntryDetailView.swift  # Full entry display
│   │   ├── EntryRow.swift         # List item component
│   │   └── StorageImageView.swift # Async image loading
│   └── FireJournalApp.swift       # App entry point
└── ShareExtension/
    └── ShareViewController.swift   # Share extension handler
```

## Setup Instructions

### Prerequisites
- Xcode 15.0 or later
- iOS 17.0+ deployment target
- CocoaPods or Swift Package Manager (for Firebase dependencies)
- Active Apple Developer account (for Share Extension capabilities)

### Installation Steps

1. **Clone the Repository**
   ```bash
   git clone https://github.com/yourusername/FireJournal.git
   cd FireJournal
   ```

2. **Open the .xcodeproj file in Xcode**

3. **Configure Firebase**
   - Create a new Firebase project at [Firebase Console](https://console.firebase.google.com)
   - Add an iOS app with your bundle identifier
   - Download `GoogleService-Info.plist`
   - Add the file to both the main app target and ShareExtension target
   - Enable Authentication (Email/Password) in Firebase Console
   - Enable Firestore Database in Firebase Console
   - Enable Storage in Firebase Console

4. **Update Bundle Identifier**
   - Change the bundle identifier in the project settings to your own
   - Update the App Group identifier to match your team

5. **Configure Capabilities**
   - Ensure App Groups capability is enabled for both targets
   - Use the same App Group for main app and Share Extension
   - Enable Push Notifications if needed