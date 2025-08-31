# Technology Stack

## Framework & Platform
- **Flutter** - Cross-platform mobile app development
- **Dart** - Programming language (SDK ^3.8.1)
- **Target Platforms**: iOS, Android, Web

## State Management & Architecture
- **flutter_riverpod** (^2.4.9) - State management solution
- **Provider pattern** - Used throughout the app for dependency injection
- **Clean architecture** - Separation of concerns with models, services, providers, and UI layers

## Key Dependencies
- **flutter_localizations** - Internationalization support
- **intl** - Internationalization and localization utilities
- **go_router** (^16.2.0) - Declarative routing
- **shared_preferences** (^2.2.2) - Local data persistence
- **cached_network_image** (^3.3.0) - Image caching and optimization
- **flutter_cache_manager** (^3.3.1) - Cache management
- **flutter_animate** (^4.5.0) - Smooth animations
- **video_player** (^2.8.2) - Video playback support

## Development Tools
- **flutter_lints** (^6.0.0) - Code quality and style enforcement
- **flutter_test** - Unit and widget testing framework

## Common Commands

### Setup & Dependencies
```bash
flutter pub get          # Install dependencies
flutter pub upgrade      # Update dependencies
flutter pub outdated     # Check for outdated packages
```

### Development
```bash
flutter run              # Run app in debug mode
flutter run --release    # Run app in release mode
flutter hot-reload       # Apply code changes (r in terminal)
flutter hot-restart      # Restart app (R in terminal)
```

### Code Quality
```bash
flutter analyze          # Static code analysis
flutter test             # Run all tests
flutter test --coverage  # Run tests with coverage
flutter format .         # Format all Dart files
```

### Localization
```bash
flutter gen-l10n         # Generate localization files
```

### Build & Deploy
```bash
flutter build apk        # Build Android APK
flutter build ios        # Build iOS app
flutter build web        # Build web version
```

## Project Configuration
- **Code generation enabled** for internationalization
- **Material Design** with custom theming
- **Custom fonts**: Primary (Aboreto), Secondary (DM Sans), Accent (Quintessential)
- **Asset organization**: images/, videos/, data/, icons/, fonts/