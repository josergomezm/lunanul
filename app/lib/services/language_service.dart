import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lunanul/utils/localization_error_handler.dart';

/// Service for managing language preferences and device locale detection
class LanguageService {
  static const String _languageKey = 'selected_language';

  /// Supported locales for the application
  static const List<Locale> supportedLocales = [
    Locale('en', ''), // English
    Locale('es', ''), // Spanish
  ];

  /// Gets the saved language preference from SharedPreferences
  /// Returns device locale if no preference is saved, or English as fallback
  Future<Locale> getSavedLanguage() async {
    return await LocalizationErrorHandler.safeAsyncOperation(
      () async {
        final prefs = await SharedPreferences.getInstance();
        final languageCode = prefs.getString(_languageKey);

        if (languageCode != null && languageCode.isNotEmpty) {
          final locale = Locale(languageCode);
          if (isSupported(locale)) {
            return locale;
          }
        }

        // If no saved language or unsupported, use device locale
        final deviceLocale = getDeviceLocale();
        final validatedLocale =
            LocalizationErrorHandler.validateAndFallbackLocale(
              deviceLocale,
              supportedLocales,
            );

        return validatedLocale;
      },
      const Locale('en'), // Fallback value
      operationName: 'getSavedLanguage',
      context: 'LanguageService',
    );
  }

  /// Saves the selected language preference to SharedPreferences
  Future<void> saveLanguage(Locale locale) async {
    // Validate locale before saving
    final validatedLocale = LocalizationErrorHandler.validateAndFallbackLocale(
      locale,
      supportedLocales,
    );

    await LocalizationErrorHandler.safeAsyncOperation(
      () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_languageKey, validatedLocale.languageCode);
      },
      null, // No return value for void operation
      operationName: 'saveLanguage',
      context: 'locale: ${validatedLocale.languageCode}',
    );
  }

  /// Gets the device's default locale
  /// Returns the system locale or English as fallback
  Locale getDeviceLocale() {
    return LocalizationErrorHandler.safeSyncOperation(
      () {
        final deviceLocale = PlatformDispatcher.instance.locale;
        return Locale(deviceLocale.languageCode);
      },
      const Locale('en'), // Fallback value
      operationName: 'getDeviceLocale',
      context: 'LanguageService',
    );
  }

  /// Checks if a locale is supported by the application
  bool isSupported(Locale locale) {
    return supportedLocales.any(
      (supportedLocale) => supportedLocale.languageCode == locale.languageCode,
    );
  }

  /// Gets the list of supported locales
  List<Locale> getSupportedLocales() {
    return List.unmodifiable(supportedLocales);
  }

  /// Clears the saved language preference
  /// Useful for testing or resetting to device default
  Future<void> clearSavedLanguage() async {
    await LocalizationErrorHandler.safeAsyncOperation(
      () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_languageKey);
      },
      null, // No return value for void operation
      operationName: 'clearSavedLanguage',
      context: 'LanguageService',
    );
  }
}
