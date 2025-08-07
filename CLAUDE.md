# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Mynt Plus** is a Flutter-based financial trading application that provides comprehensive trading, investment, and portfolio management services. The app supports multiple financial instruments including stocks, mutual funds, IPOs, bonds, and options trading.

### Core Features
- **Multi-asset Trading**: Stocks, options, futures, indices, bonds, and mutual funds
- **Portfolio Management**: Holdings, positions, P&L tracking with calendar heat maps
- **Market Data**: Real-time quotes, watchlists, market depth, option chains
- **Reports**: Ledger, trade book, tax P&L, corporate actions, pledge management
- **Fund Management**: Payment gateway integration, UPI payments, fund transfers
- **Notifications**: Firebase-based push notifications and exchange messages

## Architecture

### State Management
- **Primary**: Flutter Riverpod for reactive state management
- **Dependency Injection**: GetIt service locator pattern
- **Preferences**: SharedPreferences for local storage

### Key Architecture Patterns
- **Provider Pattern**: Centralized business logic in `/lib/provider/`
- **Repository Pattern**: API layer abstraction in `/lib/api/`
- **Model Layer**: Data models in `/lib/models/` organized by feature
- **Widget Composition**: Reusable components in `/lib/sharedWidget/`

### Project Structure
```
lib/
├── api/                 # API services and networking
├── models/              # Data models organized by feature
├── provider/            # Riverpod providers for state management
├── screens/             # UI screens organized by feature
├── sharedWidget/        # Reusable UI components
├── routes/              # Navigation routing
├── res/                 # Resources (colors, typography, themes)
├── locator/             # Dependency injection setup
├── notification/        # Firebase notification handling
└── utils/               # Utility functions
```

### Firebase Integration
- **Core Services**: Authentication, messaging, analytics, performance monitoring
- **Initialization**: Handled in `main.dart` with proper error handling
- **Push Notifications**: Comprehensive notification service with custom handling

## Development Commands

### Essential Flutter Commands
```bash
# Install dependencies
flutter pub get

# Run the app (debug mode)
flutter run                          # Mobile (Android/iOS)
flutter run -d chrome                # Web browser
flutter run -d chrome --web-port 8080 # Web with specific port

# Build for production
flutter build apk --release          # Android APK
flutter build appbundle --release    # Android App Bundle
flutter build ios --release          # iOS
flutter build web --release          # Web production build

# Code analysis and formatting
flutter analyze                      # Static analysis
flutter format .                     # Code formatting

# Run tests
flutter test                         # Unit and widget tests

# Clean build cache
flutter clean
```

### Web-Specific Commands
```bash
# Run web app locally
flutter run -d chrome --web-port 8080

# Build for web deployment
flutter build web --release

# Serve web build locally
cd build/web && python -m http.server 8080
```

### Development Workflow
1. Always run `flutter pub get` after pulling changes
2. Use `flutter analyze` before committing code
3. Format code with `flutter format .` to maintain consistency
4. Test on mobile (Android/iOS) and web platforms
5. For web testing: `flutter run -d chrome --web-port 8080`

## Key Technical Considerations

### API Integration
- **Base URL Configuration**: Managed in `/lib/api/core/api_link.dart`
- **Authentication**: Token-based auth with session validation
- **WebSocket**: Real-time market data via WebSocket connections
- **Error Handling**: Centralized error handling across all API calls

### Security Features
- **Local Authentication**: Biometric and PIN-based app lock
- **API Security**: Encrypted communication with token refresh
- **Data Protection**: Sensitive data encryption and secure storage

### Platform-Specific Features
- **Android**: Gradle configuration in `/android/app/build.gradle`
- **iOS**: Xcode project configuration with proper entitlements
- **Web**: Full web support with Firebase integration, responsive design
  - Web manifest: `/web/manifest.json`
  - HTML configuration: `/web/index.html`
  - PWA-ready with offline capabilities

### Performance Optimizations
- **Firebase Performance**: Integrated performance monitoring
- **Image Optimization**: SVG assets for scalable graphics
- **State Management**: Efficient Riverpod providers to minimize rebuilds

## Deployment

### Android
- Signing configuration in `android/app/build.gradle`
- Google Services configuration via `google-services.json`
- Target SDK: Check `build.gradle` for current version

### iOS
- Xcode project in `ios/Runner.xcodeproj`
- Firebase configuration via `GoogleService-Info.plist`
- Proper entitlements for production deployment

### Firebase Configuration
- Production and staging environments supported
- Analytics and performance monitoring enabled
- Push notification certificates configured

## Important Notes

- **State Management**: Always use Riverpod providers for shared state
- **Navigation**: Use named routes defined in `/lib/routes/`
- **Styling**: Follow theme system in `/lib/res/` for consistent UI
- **Assets**: All assets properly declared in `pubspec.yaml`
- **Testing**: Focus on critical user flows and business logic
- **Error Handling**: Implement proper error boundaries and user feedback