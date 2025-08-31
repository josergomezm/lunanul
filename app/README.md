# Lunanul Flutter App

A gentle, personalized tarot reading app focused on self-reflection and meaningful connections.

## Project Structure

```
app/
├── lib/
│   ├── main.dart              # App entry point with Riverpod setup
│   ├── models/                # Data models (TarotCard, Reading, etc.)
│   ├── services/              # Business logic services
│   ├── providers/             # Riverpod state providers
│   ├── pages/                 # App screens/pages
│   ├── widgets/               # Reusable UI components
│   └── utils/                 # Utilities and constants
│       ├── constants.dart     # App-wide constants and enums
│       └── app_theme.dart     # Theme configuration
├── assets/
│   ├── images/                # Image assets
│   └── data/                  # JSON data files
├── test/                      # Unit and widget tests
└── pubspec.yaml              # Dependencies and project config
```

## Dependencies

- **flutter_riverpod**: State management
- **cached_network_image**: Image caching for tarot cards
- **shared_preferences**: Local storage
- **go_router**: Navigation (ready for future implementation)

## Getting Started

1. Ensure Flutter is installed and configured
2. Run `flutter pub get` to install dependencies
3. Run `flutter analyze` to check for issues
4. Run `flutter test` to run tests
5. Run `flutter run` to start the app

## Development Notes

- The app uses Riverpod for state management
- Theme follows a tranquil design with calming purples and deep blues
- Project structure is organized for scalability
- All dependencies are configured and ready for development

## Next Steps

This is the foundation setup. The next tasks will involve:
1. Creating core data models
2. Implementing mock services
3. Building UI components
4. Setting up navigation
5. Implementing the main features

## Build Status

✅ Project structure created
✅ Dependencies installed
✅ Theme configured
✅ Tests passing
✅ App builds successfully