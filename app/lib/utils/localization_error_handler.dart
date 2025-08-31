import 'dart:developer' as developer;
import 'dart:ui';
import 'package:flutter/foundation.dart';

/// Comprehensive error handler for localization operations.
/// Provides centralized error logging, fallback mechanisms, and error recovery
/// strategies for all localization-related operations in the app.
class LocalizationErrorHandler {
  static const String _logTag = 'LocalizationErrorHandler';

  // Error counters for monitoring
  static int _totalErrors = 0;
  static int _fallbacksUsed = 0;
  static final Map<String, int> _errorsByType = {};
  static final Map<String, int> _errorsByKey = {};

  /// Gets a localized string with comprehensive error handling and fallback logic
  ///
  /// Fallback hierarchy:
  /// 1. Requested locale translation
  /// 2. English translation (if different from requested)
  /// 3. Custom fallback string
  /// 4. Key name as display text
  /// 5. Generic error message
  static String getLocalizedString(
    String key,
    Locale locale,
    Map<String, dynamic> translations, {
    String? fallback,
    String? context,
  }) {
    try {
      // Try requested locale
      final localizedValue = _getTranslationForLocale(
        key,
        locale,
        translations,
      );
      if (localizedValue != null && localizedValue.isNotEmpty) {
        return localizedValue;
      }

      // Fallback to English if different locale
      if (locale.languageCode != 'en') {
        final englishValue = _getTranslationForLocale(
          key,
          const Locale('en'),
          translations,
        );
        if (englishValue != null && englishValue.isNotEmpty) {
          _logFallbackUsed('English fallback', key, locale, context);
          return englishValue;
        }
      }

      // Use custom fallback
      if (fallback != null && fallback.isNotEmpty) {
        _logFallbackUsed('Custom fallback', key, locale, context);
        return fallback;
      }

      // Use key as fallback
      final keyFallback = _formatKeyAsDisplayText(key);
      _logFallbackUsed('Key fallback', key, locale, context);
      return keyFallback;
    } catch (e) {
      _logError('Translation retrieval failed', e, key, locale, context);

      // Last resort fallback
      return fallback ?? _formatKeyAsDisplayText(key);
    }
  }

  /// Gets a translation for a specific locale from the translations map
  static String? _getTranslationForLocale(
    String key,
    Locale locale,
    Map<String, dynamic> translations,
  ) {
    try {
      final localeTranslations = translations[locale.languageCode];
      if (localeTranslations is Map<String, dynamic>) {
        final value = localeTranslations[key];
        return value?.toString();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Handles JSON parsing errors with detailed logging and recovery
  static Map<String, dynamic> handleJsonParsingError(
    String assetPath,
    dynamic error, {
    String? context,
  }) {
    _logError('JSON parsing failed', error, assetPath, null, context);

    // Return empty map as fallback
    return <String, dynamic>{};
  }

  /// Handles asset loading errors with fallback strategies
  static Future<String?> handleAssetLoadingError(
    String assetPath,
    dynamic error, {
    String? context,
    String? fallbackAssetPath,
  }) async {
    _logError('Asset loading failed', error, assetPath, null, context);

    // Try fallback asset if provided
    if (fallbackAssetPath != null) {
      try {
        // This would be implemented by the calling service
        return null; // Placeholder - actual implementation depends on the service
      } catch (fallbackError) {
        _logError(
          'Fallback asset loading failed',
          fallbackError,
          fallbackAssetPath,
          null,
          context,
        );
      }
    }

    return null;
  }

  /// Validates translation completeness and logs missing translations
  static List<String> validateTranslations(
    Map<String, dynamic> translations,
    List<String> requiredKeys, {
    Locale? locale,
    String? context,
  }) {
    final missingKeys = <String>[];

    for (final key in requiredKeys) {
      final value = _getTranslationForLocale(
        key,
        locale ?? const Locale('en'),
        translations,
      );

      if (value == null || value.isEmpty) {
        missingKeys.add(key);
      }
    }

    if (missingKeys.isNotEmpty) {
      _logError(
        'Missing translations detected',
        'Keys: ${missingKeys.join(', ')}',
        context ?? 'validation',
        locale,
        context,
      );
    }

    return missingKeys;
  }

  /// Handles parameter substitution errors in localized strings
  static String handleParameterSubstitution(
    String template,
    Map<String, dynamic> parameters, {
    String? key,
    Locale? locale,
    String? context,
  }) {
    try {
      String result = template;

      for (final entry in parameters.entries) {
        final placeholder = '{${entry.key}}';
        if (result.contains(placeholder)) {
          result = result.replaceAll(placeholder, entry.value.toString());
        }
      }

      return result;
    } catch (e) {
      _logError('Parameter substitution failed', e, key, locale, context);
      return template; // Return original template as fallback
    }
  }

  /// Logs localization errors with detailed context
  static void _logError(
    String message,
    dynamic error,
    String? key,
    Locale? locale,
    String? context,
  ) {
    _totalErrors++;

    final errorType = error.runtimeType.toString();
    _errorsByType[errorType] = (_errorsByType[errorType] ?? 0) + 1;

    if (key != null) {
      _errorsByKey[key] = (_errorsByKey[key] ?? 0) + 1;
    }

    final contextInfo = context != null ? ' [Context: $context]' : '';
    final keyInfo = key != null ? ' [Key: $key]' : '';
    final localeInfo = locale != null
        ? ' [Locale: ${locale.languageCode}]'
        : '';
    final errorInfo = error != null ? ' [Error: $error]' : '';

    final logMessage = '$message$contextInfo$keyInfo$localeInfo$errorInfo';

    developer.log(
      logMessage,
      name: _logTag,
      level: 1000, // Severe level
      error: error,
    );

    if (kDebugMode) {
      debugPrint('[$_logTag] $logMessage');
    }
  }

  /// Logs when fallback mechanisms are used
  static void _logFallbackUsed(
    String fallbackType,
    String key,
    Locale locale,
    String? context,
  ) {
    _fallbacksUsed++;

    final contextInfo = context != null ? ' [Context: $context]' : '';
    final logMessage =
        '$fallbackType used for key "$key" (${locale.languageCode})$contextInfo';

    developer.log(
      logMessage,
      name: _logTag,
      level: 800, // Info level
    );

    if (kDebugMode) {
      debugPrint('[$_logTag] $logMessage');
    }
  }

  /// Formats a key as display text (fallback utility)
  static String _formatKeyAsDisplayText(String key) {
    return key
        .replaceAll('_', ' ')
        .replaceAll('-', ' ')
        .split(' ')
        .map(
          (word) => word.isEmpty
              ? ''
              : word[0].toUpperCase() + word.substring(1).toLowerCase(),
        )
        .join(' ');
  }

  /// Gets error statistics for monitoring and debugging
  static Map<String, dynamic> getErrorStatistics() {
    return {
      'totalErrors': _totalErrors,
      'fallbacksUsed': _fallbacksUsed,
      'errorsByType': Map<String, int>.from(_errorsByType),
      'errorsByKey': Map<String, int>.from(_errorsByKey),
      'errorRate': _totalErrors > 0 ? (_fallbacksUsed / _totalErrors) : 0.0,
    };
  }

  /// Resets error statistics (useful for testing)
  static void resetStatistics() {
    _totalErrors = 0;
    _fallbacksUsed = 0;
    _errorsByType.clear();
    _errorsByKey.clear();
  }

  /// Checks if error rate is above threshold (for monitoring)
  static bool isErrorRateHigh({double threshold = 0.1}) {
    if (_totalErrors == 0) return false;
    return (_fallbacksUsed / _totalErrors) > threshold;
  }

  /// Creates a safe wrapper for async localization operations
  static Future<T> safeAsyncOperation<T>(
    Future<T> Function() operation,
    T fallbackValue, {
    String? operationName,
    String? context,
  }) async {
    try {
      return await operation();
    } catch (e) {
      _logError(
        'Async localization operation failed',
        e,
        operationName,
        null,
        context,
      );
      return fallbackValue;
    }
  }

  /// Creates a safe wrapper for sync localization operations
  static T safeSyncOperation<T>(
    T Function() operation,
    T fallbackValue, {
    String? operationName,
    String? context,
  }) {
    try {
      return operation();
    } catch (e) {
      _logError(
        'Sync localization operation failed',
        e,
        operationName,
        null,
        context,
      );
      return fallbackValue;
    }
  }

  /// Validates locale support and provides fallback
  static Locale validateAndFallbackLocale(
    Locale requestedLocale,
    List<Locale> supportedLocales,
  ) {
    // Check exact match
    for (final supported in supportedLocales) {
      if (supported.languageCode == requestedLocale.languageCode &&
          supported.countryCode == requestedLocale.countryCode) {
        return supported;
      }
    }

    // Check language code match
    for (final supported in supportedLocales) {
      if (supported.languageCode == requestedLocale.languageCode) {
        _logFallbackUsed(
          'Locale fallback',
          'locale',
          requestedLocale,
          'country code not supported',
        );
        return supported;
      }
    }

    // Fallback to English or first supported locale
    final englishLocale = supportedLocales.firstWhere(
      (locale) => locale.languageCode == 'en',
      orElse: () => supportedLocales.first,
    );

    _logFallbackUsed(
      'Locale fallback to default',
      'locale',
      requestedLocale,
      'language not supported',
    );

    return englishLocale;
  }
}

/// Extension for safe localization operations on common types
extension SafeLocalizationOperations on Map<String, dynamic> {
  /// Safely gets a string value with fallback
  String safeGetString(String key, {String fallback = ''}) {
    return LocalizationErrorHandler.safeSyncOperation(
      () {
        final value = this[key];
        if (value is String && value.isNotEmpty) {
          return value;
        }
        return fallback;
      },
      fallback,
      operationName: 'safeGetString',
      context: key,
    );
  }

  /// Safely gets a list of strings with fallback
  List<String> safeGetStringList(
    String key, {
    List<String> fallback = const [],
  }) {
    return LocalizationErrorHandler.safeSyncOperation(
      () {
        final value = this[key];
        if (value is List) {
          return value.map((item) => item.toString()).toList();
        }
        return fallback;
      },
      fallback,
      operationName: 'safeGetStringList',
      context: key,
    );
  }

  /// Safely gets a nested map with fallback
  Map<String, dynamic> safeGetMap(
    String key, {
    Map<String, dynamic> fallback = const {},
  }) {
    return LocalizationErrorHandler.safeSyncOperation(
      () {
        final value = this[key];
        if (value is Map<String, dynamic>) {
          return value;
        }
        return fallback;
      },
      fallback,
      operationName: 'safeGetMap',
      context: key,
    );
  }
}
