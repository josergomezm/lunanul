# Project Structure & Organization

## Root Directory Structure
```
app/
├── lib/                    # Main application code
├── assets/                 # Static assets (images, data, fonts)
├── test/                   # Unit and integration tests
├── android/                # Android-specific configuration
├── ios/                    # iOS-specific configuration
├── web/                    # Web-specific configuration
├── pubspec.yaml           # Dependencies and project configuration
├── l10n.yaml              # Localization configuration
└── analysis_options.yaml  # Code analysis rules
```

## lib/ Directory Organization

### Core Structure
```
lib/
├── main.dart              # App entry point with Riverpod setup
├── models/                # Data models and entities
├── services/              # Business logic and external integrations
├── providers/             # Riverpod state providers
├── pages/                 # App screens/pages
├── widgets/               # Reusable UI components
├── utils/                 # Utilities and constants
└── l10n/                  # Localization files
```

### Detailed Organization

#### models/
- Data classes and entities (TarotCard, Reading, User, etc.)
- Immutable data structures
- JSON serialization/deserialization

#### services/
- Business logic layer
- API integrations
- Local storage operations
- Image caching and management
- Localization services

#### providers/
- Riverpod state providers
- State management logic
- Provider dependencies and composition

#### pages/
- Full-screen UI components
- Route-level widgets
- Page-specific state management

#### widgets/
- Reusable UI components
- Custom widgets
- Shared animations and effects

#### utils/
- `constants.dart` - App-wide constants and enums
- `app_theme.dart` - Theme configuration
- `app_router.dart` - Navigation setup
- Helper functions and utilities

#### l10n/
- `app_en.arb` - English translations
- `app_es.arb` - Spanish translations
- `generated/` - Auto-generated localization files

## assets/ Directory Structure
```
assets/
├── images/                # UI images and illustrations
├── videos/                # Video content
├── data/                  # JSON data files (tarot cards, etc.)
├── icons/                 # App icons and symbols
└── fonts/                 # Custom font files
```

## Naming Conventions

### Files & Directories
- Use `snake_case` for file and directory names
- Suffix widgets with `_widget.dart`
- Suffix pages with `_page.dart`
- Suffix services with `_service.dart`
- Suffix providers with `_provider.dart`

### Classes & Variables
- Use `PascalCase` for class names
- Use `camelCase` for variables and methods
- Use `SCREAMING_SNAKE_CASE` for constants

### Assets
- Use descriptive names with underscores
- Group by type and feature
- Include size indicators where relevant (e.g., `icon_24.png`)

## Architecture Patterns

### Clean Architecture Layers
1. **Presentation Layer** (pages/, widgets/)
2. **Application Layer** (providers/)
3. **Domain Layer** (models/)
4. **Infrastructure Layer** (services/)

### State Management Flow
- UI widgets consume providers
- Providers manage state and business logic
- Services handle external dependencies
- Models define data structures

### Testing Structure
- Mirror the lib/ structure in test/
- Unit tests for services and models
- Widget tests for UI components
- Integration tests for complete flows