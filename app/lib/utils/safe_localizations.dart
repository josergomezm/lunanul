import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:lunanul/l10n/generated/app_localizations.dart';

/// Utility class for safe localization handling with comprehensive error handling
/// and fallback mechanisms. Provides graceful degradation when translations
/// are missing or when localization errors occur.
class SafeLocalizations {
  static const String _logTag = 'SafeLocalizations';

  /// Safely gets a localized string using the provided getter function.
  /// Provides multiple levels of fallback:
  /// 1. Try the requested localization
  /// 2. Fall back to English if available
  /// 3. Use the provided fallback string
  /// 4. Use a generic error message as last resort
  static String safeGet(
    BuildContext context,
    String Function(AppLocalizations) getter, {
    String? fallback,
    String? key,
  }) {
    try {
      final localizations = AppLocalizations.of(context);
      final result = getter(localizations);
      if (result.isNotEmpty) {
        return result;
      }
    } catch (e) {
      _logLocalizationError('Failed to get localization', e, key: key);
    }

    // Try English fallback if current locale is not English
    try {
      final currentLocale = Localizations.localeOf(context);
      if (currentLocale.languageCode != 'en') {
        final englishLocalizations = _getEnglishLocalizations(context);
        if (englishLocalizations != null) {
          final result = getter(englishLocalizations);
          if (result.isNotEmpty) {
            _logFallbackUsed('English fallback used', key: key);
            return result;
          }
        }
      }
    } catch (e) {
      _logLocalizationError('English fallback failed', e, key: key);
    }

    // Use provided fallback
    if (fallback != null && fallback.isNotEmpty) {
      _logFallbackUsed('Custom fallback used', key: key);
      return fallback;
    }

    // Last resort fallback
    final lastResort = key ?? 'Translation missing';
    _logLocalizationError(
      'All fallbacks failed, using last resort',
      null,
      key: key,
    );
    return lastResort;
  }

  /// Safely gets a localized string with parameters.
  /// Handles cases where parameter substitution might fail.
  static String safeGetWithParams(
    BuildContext context,
    String Function(AppLocalizations) getter, {
    String? fallback,
    String? key,
    Map<String, dynamic>? params,
  }) {
    try {
      final result = safeGet(context, getter, fallback: fallback, key: key);

      // If we have parameters, try to substitute them
      if (params != null && params.isNotEmpty) {
        return _substituteParameters(result, params);
      }

      return result;
    } catch (e) {
      _logLocalizationError('Parameter substitution failed', e, key: key);
      return fallback ?? key ?? 'Translation error';
    }
  }

  /// Gets a localized string or returns null if not available.
  /// Useful when you want to check if a translation exists without fallbacks.
  static String? tryGet(
    BuildContext context,
    String Function(AppLocalizations) getter,
  ) {
    try {
      final localizations = AppLocalizations.of(context);
      final result = getter(localizations);
      if (result.isNotEmpty) {
        return result;
      }
    } catch (e) {
      // Silently fail for try operations
    }
    return null;
  }

  /// Checks if a localization is available for the current locale
  static bool isAvailable(
    BuildContext context,
    String Function(AppLocalizations) getter,
  ) {
    return tryGet(context, getter) != null;
  }

  /// Gets the current locale or falls back to English
  static Locale getCurrentLocale(BuildContext context) {
    try {
      return Localizations.localeOf(context);
    } catch (e) {
      _logLocalizationError('Failed to get current locale', e);
      return const Locale('en');
    }
  }

  /// Checks if the current locale is supported
  static bool isCurrentLocaleSupported(BuildContext context) {
    try {
      final currentLocale = getCurrentLocale(context);
      return AppLocalizations.supportedLocales.any(
        (locale) => locale.languageCode == currentLocale.languageCode,
      );
    } catch (e) {
      _logLocalizationError('Failed to check locale support', e);
      return false;
    }
  }

  /// Gets English localizations for fallback purposes
  static AppLocalizations? _getEnglishLocalizations(BuildContext context) {
    try {
      // Create a temporary context with English locale
      return lookupAppLocalizations(const Locale('en'));
    } catch (e) {
      _logLocalizationError('Failed to get English localizations', e);
      return null;
    }
  }

  /// Substitutes parameters in a localized string
  static String _substituteParameters(
    String text,
    Map<String, dynamic> params,
  ) {
    String result = text;

    for (final entry in params.entries) {
      final placeholder = '{${entry.key}}';
      if (result.contains(placeholder)) {
        result = result.replaceAll(placeholder, entry.value.toString());
      }
    }

    return result;
  }

  /// Logs localization errors for debugging and monitoring
  static void _logLocalizationError(
    String message,
    dynamic error, {
    String? key,
  }) {
    final keyInfo = key != null ? ' (key: $key)' : '';
    final errorInfo = error != null ? ' - Error: $error' : '';

    developer.log(
      '$message$keyInfo$errorInfo',
      name: _logTag,
      level: 900, // Warning level
    );

    // In debug mode, also print to console for immediate visibility
    if (kDebugMode) {
      debugPrint('[$_logTag] $message$keyInfo$errorInfo');
    }
  }

  /// Logs when fallback mechanisms are used
  static void _logFallbackUsed(String message, {String? key}) {
    final keyInfo = key != null ? ' (key: $key)' : '';

    developer.log(
      '$message$keyInfo',
      name: _logTag,
      level: 800, // Info level
    );

    // In debug mode, also print to console
    if (kDebugMode) {
      debugPrint('[$_logTag] $message$keyInfo');
    }
  }

  /// Validates that all required localizations are available
  /// Returns a list of missing translation keys
  static List<String> validateLocalizations(
    BuildContext context,
    Map<String, String Function(AppLocalizations)> requiredTranslations,
  ) {
    final missingKeys = <String>[];

    for (final entry in requiredTranslations.entries) {
      if (!isAvailable(context, entry.value)) {
        missingKeys.add(entry.key);
      }
    }

    if (missingKeys.isNotEmpty) {
      _logLocalizationError(
        'Missing translations found',
        null,
        key: missingKeys.join(', '),
      );
    }

    return missingKeys;
  }

  /// Preloads and validates critical localizations
  /// Should be called during app initialization
  static Future<void> preloadAndValidate(BuildContext context) async {
    try {
      // Test basic localizations
      final testTranslations = {
        'appTitle': (AppLocalizations l) => l.appTitle,
        'homeTitle': (AppLocalizations l) => l.homeTitle,
        'loading': (AppLocalizations l) => l.loading,
        'error': (AppLocalizations l) => l.error,
      };

      final missingKeys = validateLocalizations(context, testTranslations);

      if (missingKeys.isEmpty) {
        developer.log(
          'Localization validation passed',
          name: _logTag,
          level: 700, // Info level
        );
      } else {
        _logLocalizationError(
          'Localization validation failed',
          'Missing keys: ${missingKeys.join(', ')}',
        );
      }
    } catch (e) {
      _logLocalizationError('Localization preload failed', e);
    }
  }
}

/// Extension on BuildContext for convenient safe localization access
extension SafeLocalizationsExtension on BuildContext {
  /// Safely gets a localized string with automatic error handling
  String safeL10n(
    String Function(AppLocalizations) getter, {
    String? fallback,
    String? key,
  }) {
    return SafeLocalizations.safeGet(
      this,
      getter,
      fallback: fallback,
      key: key,
    );
  }

  /// Safely gets a localized string with parameters
  String safeL10nWithParams(
    String Function(AppLocalizations) getter, {
    String? fallback,
    String? key,
    Map<String, dynamic>? params,
  }) {
    return SafeLocalizations.safeGetWithParams(
      this,
      getter,
      fallback: fallback,
      key: key,
      params: params,
    );
  }

  /// Tries to get a localized string, returns null if not available
  String? tryL10n(String Function(AppLocalizations) getter) {
    return SafeLocalizations.tryGet(this, getter);
  }
}
