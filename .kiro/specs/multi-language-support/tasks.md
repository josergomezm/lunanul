# Implementation Plan

- [x] 1. Set up Flutter internationalization infrastructure





  - Add flutter_localizations and intl dependencies to pubspec.yaml
  - Create l10n.yaml configuration file for code generation
  - Enable flutter generate in pubspec.yaml
  - _Requirements: 1.1, 1.4_
-

- [x] 2. Create base localization files and structure




  - [x] 2.1 Create ARB files for English and Spanish UI text


    - Create lib/l10n/app_en.arb with all UI strings from existing pages
    - Create lib/l10n/app_es.arb with Spanish translations
    - Include proper ARB metadata and placeholders for dynamic content
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5_

  - [x] 2.2 Create JSON files for dynamic tarot content


    - Create assets/data/tarot_cards_en.json with card names and meanings
    - Create assets/data/tarot_cards_es.json with Spanish card translations
    - Create assets/data/journal_prompts_en.json with English prompts
    - Create assets/data/journal_prompts_es.json with Spanish prompts
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 4.1, 4.2, 4.3, 4.4, 4.5_

- [x] 3. Implement core language management services




  - [x] 3.1 Create LanguageService for persistence and device detection


    - Write LanguageService class with SharedPreferences integration
    - Implement getSavedLanguage, saveLanguage, and getDeviceLocale methods
    - Add language validation and fallback logic
    - Write unit tests for LanguageService functionality
    - _Requirements: 1.1, 1.4, 1.5_

  - [x] 3.2 Create TarotCardLocalizations service for dynamic card content


    - Write TarotCardLocalizations class to load and parse JSON files
    - Implement methods for card names, meanings, and keywords by locale
    - Add error handling and fallback mechanisms for missing translations
    - Write unit tests for card localization functionality
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 5.1, 5.2, 5.3, 5.4, 5.5_

  - [x] 3.3 Create DynamicContentLocalizations service for prompts and descriptions


    - Write DynamicContentLocalizations class for journal prompts and topic descriptions
    - Implement methods to get localized prompts and topic information
    - Add caching and memory management for loaded content
    - Write unit tests for dynamic content localization
    - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5, 5.1, 5.2, 5.3, 5.4, 5.5_
-

- [x] 4. Set up Riverpod providers for language state management




  - Create LanguageNotifier StateNotifier for language state management
  - Implement languageProvider, languageServiceProvider, and localization providers
  - Add initialization logic to load saved language on app start
  - Write unit tests for language providers and state management
  - _Requirements: 1.1, 1.4, 1.5_

- [x] 5. Configure MaterialApp with localization delegates





  - Update main.dart to include localization delegates and supported locales
  - Integrate language provider with MaterialApp.locale
  - Add proper locale resolution and fallback handling
  - Test app startup with different device languages
  - _Requirements: 1.1, 1.2, 1.3, 5.1, 5.2, 5.3, 5.4, 5.5_

- [x] 6. Update existing pages to use localized strings
  - [x] 6.1 Localize HomePage UI elements
    - Replace hardcoded strings in HomePage with AppLocalizations calls
    - Update greeting logic to use localized time-based messages
    - Localize card of the day section, recent readings, and journal prompt text
    - Test HomePage with both English and Spanish languages
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 4.1, 4.2, 4.3, 4.4, 4.5_
  - [x] 6.2 Localize InterpretationsPage UI elements
    - Replace hardcoded strings in InterpretationsPage with AppLocalizations calls
    - Update topic selection, card selection, and action button text
    - Localize dialog content, error messages, and loading states
    - Test InterpretationsPage with both languages
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5_
  - [x] 6.3 Update remaining pages and widgets with localized text
    - Localize all remaining pages, dialogs, and reusable widgets
    - Update error messages, loading states, and user feedback text
    - Ensure consistent localization across all UI components
    - Test all pages and widgets with language switching
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5_
-

- [x] 7. Integrate tarot card localization with existing card system
  - Update TarotCard model to support localized names and meanings
  - Modify CardWidget to display localized card information
  - Update card services to use TarotCardLocalizations for content
  - Test card display and interpretation with both languages
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 6.1, 6.2, 6.3, 6.4, 6.5_


- [x] 8. Implement language selection UI in settings






  - Create language selection widget with English and Spanish options
  - Add language selection to app settings or preferences page
  - Implement immediate language switching with provider updates




  - Add visual feedback for current language selection
  - Test language selection UI and immediate switching functionality
  - _Requirements: 1.2, 1.3, 1.4, 1.5_

- [x] 9. Update journal prompts to use localized content

  - Modify journal prompt logic to use DynamicContentLocalizations
  - Update daily reflection section to show localized prompts
  - Ensure prompt rotation works correctly with localized content
  - Test journal prompt display and rotation in both languages
  - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5, 6.1, 6.2, 6.3, 6.4, 6.5_

- [x] 10. Implement date and time localization





  - Add proper date formatting using intl package for each locale
  - Update all date displays to use localized formatting
  - Implement time-based greeting logic with proper locale support
  - Test date and time display with both English and Spanish locales
  - _Requirements: 4.3, 4.4, 4.5_
- [x] 11. Add comprehensive error handling and fallback mechanisms




- [x] 11. Add comprehensive error handling and fallback mechanisms

  - Implement SafeLocalizations utility for graceful error handling
  - Add fallback logic for missing translations throughout the app
  - Create error logging for missing or failed translations
  - Test error scenarios and fallback behavior
  - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5_
