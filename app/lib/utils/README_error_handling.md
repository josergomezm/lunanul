# Localization Error Handling and Fallback Mechanisms

This document describes the comprehensive error handling and fallback mechanisms implemented for the multi-language support feature in Lunanul.

## Overview

The error handling system provides multiple layers of fallback to ensure the app never displays broken or missing translations to users. It includes logging, monitoring, and graceful degradation strategies.

## Core Components

### 1. SafeLocalizations Utility

The `SafeLocalizations` class provides safe access to Flutter's generated localizations with automatic error handling.

#### Basic Usage

```dart
import 'package:lunanul/utils/safe_localizations.dart';

// Safe localization access
final title = SafeLocalizations.safeGet(
  context,
  (l) => l.appTitle,
  fallback: 'Lunanul',
  key: 'appTitle',
);

// Using the extension method
final greeting = context.safeL10n(
  (l) => l.goodMorning,
  fallback: 'Good morning',
  key: 'goodMorning',
);
```

#### Features

- **Automatic fallback**: Falls back to English if current locale fails
- **Custom fallbacks**: Supports custom fallback strings
- **Parameter handling**: Safe parameter substitution
- **Validation**: Checks translation availability
- **Logging**: Comprehensive error logging

### 2. LocalizationErrorHandler

The `LocalizationErrorHandler` provides centralized error handling for all localization operations.

#### Key Methods

```dart
// Safe string retrieval with fallback hierarchy
final text = LocalizationErrorHandler.getLocalizedString(
  'greeting',
  locale,
  translations,
  fallback: 'Hello',
  context: 'HomePage',
);

// Safe async operations
final result = await LocalizationErrorHandler.safeAsyncOperation(
  () async => riskyAsyncOperation(),
  fallbackValue,
  operationName: 'loadTranslations',
  context: 'ServiceName',
);

// Parameter substitution with error handling
final message = LocalizationErrorHandler.handleParameterSubstitution(
  'Hello {name}!',
  {'name': 'User'},
  key: 'greeting',
  locale: locale,
);
```

#### Error Statistics

```dart
// Get error statistics for monitoring
final stats = LocalizationErrorHandler.getErrorStatistics();
print('Total errors: ${stats['totalErrors']}');
print('Fallbacks used: ${stats['fallbacksUsed']}');
print('Error rate: ${stats['errorRate']}');

// Check if error rate is high
if (LocalizationErrorHandler.isErrorRateHigh(threshold: 0.1)) {
  // Handle high error rate scenario
}
```

### 3. Enhanced Service Error Handling

All localization services have been enhanced with comprehensive error handling:

#### TarotCardLocalizations

```dart
// Automatically handles missing cards, asset loading errors, and locale fallbacks
final cardName = await tarotCardLocalizations.getCardName(cardId, locale);
final meaning = await tarotCardLocalizations.getUprightMeaning(cardId, locale);
```

#### DynamicContentLocalizations

```dart
// Handles missing prompts, invalid indices, and asset errors
final prompt = await dynamicContentLocalizations.getRandomJournalPrompt(locale);
final dailyPrompt = await dynamicContentLocalizations.getDailyJournalPrompt(date, locale);
```

#### LanguageService

```dart
// Handles SharedPreferences errors and invalid locales
final savedLocale = await languageService.getSavedLanguage();
await languageService.saveLanguage(locale); // Validates locale before saving
```

## Fallback Hierarchy

The system implements a comprehensive fallback hierarchy:

### 1. UI Text Localization
1. **Primary**: Requested locale translation
2. **Secondary**: English translation (if different from requested)
3. **Tertiary**: Custom fallback string
4. **Quaternary**: Key name as display text
5. **Final**: Generic error message

### 2. Dynamic Content Localization
1. **Primary**: Requested locale content
2. **Secondary**: English content (if different from requested)
3. **Tertiary**: Default fallback content
4. **Final**: Hard-coded fallback strings

### 3. Locale Validation
1. **Primary**: Exact locale match (language + country)
2. **Secondary**: Language match (ignore country)
3. **Tertiary**: English locale
4. **Final**: First supported locale

## Error Logging and Monitoring

### Log Levels

- **Severe (1000)**: Critical errors that affect functionality
- **Warning (900)**: Non-critical errors with successful fallbacks
- **Info (800)**: Fallback usage notifications

### Log Format

```
[LocalizationErrorHandler] Message [Context: context] [Key: key] [Locale: locale] [Error: error]
```

### Monitoring Features

- **Error counting**: Tracks total errors and fallback usage
- **Error categorization**: Groups errors by type and key
- **Rate monitoring**: Calculates error rates and thresholds
- **Statistics export**: Provides detailed error statistics

## Safe Map Operations Extension

The system includes safe operations for working with translation data:

```dart
// Safe string retrieval
final value = map.safeGetString('key', fallback: 'default');

// Safe list retrieval
final list = map.safeGetStringList('key', fallback: ['default']);

// Safe nested map retrieval
final nested = map.safeGetMap('key', fallback: {'default': 'value'});
```

## Best Practices

### 1. Always Use Safe Methods

```dart
// ✅ Good - Uses safe localization
final title = context.safeL10n((l) => l.appTitle, key: 'appTitle');

// ❌ Avoid - Direct access without error handling
final title = AppLocalizations.of(context).appTitle;
```

### 2. Provide Meaningful Fallbacks

```dart
// ✅ Good - Meaningful fallback
final greeting = context.safeL10n(
  (l) => l.goodMorning,
  fallback: 'Good morning',
  key: 'goodMorning',
);

// ❌ Avoid - Generic fallback
final greeting = context.safeL10n((l) => l.goodMorning);
```

### 3. Include Context Information

```dart
// ✅ Good - Includes context for debugging
final result = LocalizationErrorHandler.safeAsyncOperation(
  () => loadData(),
  fallback,
  operationName: 'loadUserData',
  context: 'UserProfilePage',
);
```

### 4. Monitor Error Rates

```dart
// Regular monitoring in production
void checkLocalizationHealth() {
  if (LocalizationErrorHandler.isErrorRateHigh()) {
    // Log warning or send analytics
    analytics.logEvent('high_localization_error_rate');
  }
}
```

## Testing Error Scenarios

### Unit Tests

```dart
test('handles missing translation gracefully', () {
  final result = SafeLocalizations.safeGet(
    context,
    (l) => throw Exception('Missing translation'),
    fallback: 'Fallback',
    key: 'testKey',
  );
  
  expect(result, equals('Fallback'));
});
```

### Integration Tests

```dart
test('service handles asset loading errors', () async {
  // Test with non-existent asset
  final result = await service.getContent('non_existent', locale);
  
  // Should return fallback, not throw
  expect(result, isNotEmpty);
});
```

## Performance Considerations

### Caching Strategy

- **Translation caching**: Parsed translations are cached in memory
- **Error result caching**: Fallback results are not cached to allow recovery
- **Statistics caching**: Error statistics are maintained in memory

### Memory Management

- **Cache clearing**: Services provide cache clearing methods
- **Bounded statistics**: Error statistics have reasonable bounds
- **Lazy loading**: Translations loaded only when needed

## Debugging and Troubleshooting

### Enable Debug Logging

In debug mode, all localization errors are printed to the console for immediate visibility.

### Check Error Statistics

```dart
final stats = LocalizationErrorHandler.getErrorStatistics();
debugPrint('Localization stats: $stats');
```

### Validate Translations

```dart
final missingKeys = SafeLocalizations.validateLocalizations(
  context,
  requiredTranslations,
);
if (missingKeys.isNotEmpty) {
  debugPrint('Missing translations: $missingKeys');
}
```

### Reset Statistics for Testing

```dart
LocalizationErrorHandler.resetStatistics();
```

## Migration Guide

### Updating Existing Code

1. **Replace direct AppLocalizations calls**:
   ```dart
   // Before
   final title = AppLocalizations.of(context).appTitle;
   
   // After
   final title = context.safeL10n((l) => l.appTitle, key: 'appTitle');
   ```

2. **Add error handling to service calls**:
   ```dart
   // Before
   final name = await cardService.getCardName(id, locale);
   
   // After - Already handled in enhanced services
   final name = await cardService.getCardName(id, locale); // Now safe
   ```

3. **Update error handling patterns**:
   ```dart
   // Before
   try {
     final result = await riskyOperation();
     return result;
   } catch (e) {
     return fallback;
   }
   
   // After
   return await LocalizationErrorHandler.safeAsyncOperation(
     () => riskyOperation(),
     fallback,
     operationName: 'riskyOperation',
   );
   ```

## Conclusion

The comprehensive error handling and fallback mechanisms ensure that Lunanul provides a robust, user-friendly experience even when localization errors occur. The system gracefully degrades through multiple fallback levels while providing detailed logging and monitoring capabilities for debugging and maintenance.